//
//  WKWebViewPlayer.swift
//  VoiceTube_iOS
//
//  Created by TsauPoPo on 2017/7/11.
//  Copyright © 2017年 VoiceTube. All rights reserved.
//

import Foundation
import WebKit
import RxSwift
import RxCocoa
import Alamofire

protocol WKWebViewPlayerProtocol {
    var replay: Variable<Bool> { get }
    var state: Variable<PlayerState> { get }
    var quality: Variable<PlayerQuality> { get }
    var ready: Variable<Bool> { get }
    var error: Variable<PlayerError?> { get }
    var currentTime: Variable<CGFloat> { get }
    var duration: Variable<CGFloat> { get }
    var availableQualityLevels: Variable<[PlayerQuality]> { get }

    func asView() -> UIView
    func loadVideoID(videoID: String) -> Single<Void>
    func play() -> Single<Void>
    func pause() -> Single<Void>
    func stop() -> Single<Void>
    func seekTo(time: CGFloat) -> Single<Void>
    func setReplay(rePlay: Bool)
    func setQuality(quality: PlayerQuality) -> Single<Void>
    func removeScriptHandler() // remove ScriptHandler avoiding WKWebView leak 
}

// iframe player enums reference: https://developers.google.com/youtube/iframe_api_reference
enum PlayerState: Int, Equatable {
    case unstarted = -1
    case ended = 0
    case playing = 1
    case paused = 2
    case buffering = 3
    case videoCued = 4
    case ready = 99999 // custom state

    init?(state: Int) {
        switch state {
        case -1:
            self = .unstarted
        case 0:
            self = .ended
        case 1:
            self = .playing
        case 2:
            self = .paused
        case 3:
            self = .buffering
        case 4:
            self = .videoCued
        case 99999:
            self = .ready
        default:
            return nil
        }
    }
}

enum PlayerQuality: String {
    case small = "240 p"
    case medium = "360 p"
    case large = "480 p"
    case hd720 = "720 p"
    case hd1080 = "1080 p"
    case highres = "Full HD"

    init?(quality: String) {
        switch quality {
        case "small":
            self = .small
        case "medium":
            self = .medium
        case "large":
            self = .large
        case "hd720":
            self = .hd720
        case "hd1080":
            self = .hd1080
        case "highres":
            self = .highres
        default:
            return nil
        }
    }
}

enum PlayerError: Error, Equatable {

    enum WebViewPlayerError: Error, Equatable {
        case unknown
        case invalidParameter
        case cannotPlay
        case videoNotFound
        case notAllowPlayIniFrame

        init(errorCode: Int = 9999) {
            switch errorCode {
            case 2:
                self = .invalidParameter
            case 5:
                self = .cannotPlay
            case 100:
                self = .videoNotFound
            case 101, 150:
                self = .notAllowPlayIniFrame
            default:
                self = .unknown
            }
        }

        static func ==(lhs: WebViewPlayerError, rhs: WebViewPlayerError) -> Bool {
            switch (lhs, rhs) {
            case (.unknown, .unknown):
                return true
            case (.invalidParameter, .invalidParameter):
                return true
            case (.cannotPlay, .cannotPlay):
                return true
            case (.videoNotFound, .videoNotFound):
                return true
            case (.notAllowPlayIniFrame, .notAllowPlayIniFrame):
                return true
            default:
                return false
            }
        }
    }

    case loadVideoIdError
    case playError
    case pauseError
    case stopError
    case seekToError
    case setReplayError
    case setQualityError
    case webviewPlayerError(WebViewPlayerError)

    static func ==(lhs: PlayerError, rhs: PlayerError) -> Bool {
        switch (lhs, rhs) {
        case (.loadVideoIdError, .loadVideoIdError):
            return true
        case (.playError, .playError):
            return true
        case (.pauseError, .pauseError):
            return true
        case (.stopError, .stopError):
            return true
        case (.seekToError, .seekToError):
            return true
        case (.setReplayError, .setReplayError):
            return true
        case (.setQualityError, .setQualityError):
            return true
        case let (.webviewPlayerError(wkerror1), .webviewPlayerError(wkerror2)):
            return wkerror1 == wkerror2
        default:
            return false
        }
    }
}

// Custom Event with js (YTPlayer.html)
enum PlayerEvent: String {
    case onReady
    case onStateChange
    case onPlaybackQualityChange
    case onPlayerError = "onError"
    case onPlaybackRateChange
}

class WKWebViewPlayer: UIView, WKWebViewPlayerProtocol {

    public var baseURL = "about:blank"

    open var playerVars = [
        "playsinline": "1",
        "controls": "0",
        "showinfo": "0",
        "rel": "0",
        "modestbranding": "1",
    ]

    let scriptMessageName = "voicetube"
    var videoId: String = ""

    var replay: Variable<Bool> = Variable(false)
    var state: Variable<PlayerState> = Variable(.unstarted)
    var quality: Variable<PlayerQuality> = Variable(.medium)
    var ready: Variable<Bool> = Variable(false)
    var error: Variable<PlayerError?> = Variable(nil)
    var currentTime: Variable<CGFloat> = Variable(0)
    var duration: Variable<CGFloat> = Variable(0)
    var availableQualityLevels: Variable<[PlayerQuality]> = Variable([PlayerQuality]())
    lazy var networkRechable: () -> Single<Void> = self.networkReachable

    lazy var userContentController: WKUserContentController = {
        let controller = WKUserContentController()
        controller.add(self, name: self.scriptMessageName)
        return controller
    }()
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController = self.userContentController
        config.allowsInlineMediaPlayback = true
        config.requiresUserActionForMediaPlayback = false
        let webview = WKWebView(frame: CGRect.zero, configuration: config)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.isOpaque = false
        webview.backgroundColor = UIColor.clear
        webview.scrollView.isScrollEnabled = false
        return webview
    }()

    var timer: Timer! = {
        return Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
    }()

    let disposeBag = DisposeBag()
    var didUpdateConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        webView.frame = bounds
        addSubview(webView)
        
        state.asObservable().subscribe(onNext: { [unowned self] state in
            if state != .playing {
                self.timer.invalidate()
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.updateCurrentTime), userInfo: nil, repeats: true)
            }

            switch state {
            case .playing:
                self.getAvailableQualityLevels().retry(3).subscribe().disposed(by: self.disposeBag)
//            case .ended:
//                self.play().subscribe().disposed(by: self.disposeBag)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        if !didUpdateConstraints {
            webView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            didUpdateConstraints = true
        }
        super.updateConstraints()
    }
    
    func removeScriptHandler() {
        timer.invalidate()
        timer = nil
        userContentController.removeScriptMessageHandler(forName: scriptMessageName)
    }

    func loadWKWebView(_ playerVars: [String: Any]) {

        // Get HTML from player file in bundle
        let rawHTMLString = htmlStringWithFilePath(playerHTMLPath())!

        // Get JSON serialized parameters string
        let jsonPlayerVars = Utilities.serializedJSON(playerVars)!

        // Replace %@playerVars@ in rawHTMLString with jsonParameters string
        // Replace %@videoId@ in rawHTMLString with videoId
        var htmlString = rawHTMLString.replacingOccurrences(of: "%@playerVars@", with: jsonPlayerVars)
        htmlString = htmlString.replacingOccurrences(of: "%@videoId@", with: "\"\(videoId)\"")

        // Load HTML in web view
        webView.loadHTMLString(htmlString, baseURL: URL(string: baseURL))
    }

    // MARK: Helper functions
    fileprivate func playerHTMLPath() -> String {
        return Bundle(for: WKWebViewPlayer.self).path(forResource: "YTPlayer", ofType: "html")!
    }

    fileprivate func htmlStringWithFilePath(_ path: String) -> String? {
        do {
            // Get HTML string from path
            let htmlString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
            return htmlString as String
        } catch _ {
            // Error fetching HTML
            print("WKWebViewPlayerer Lookup error: no HTML file found for path")
            return nil
        }
    }

    // MARK: Command actions

    @objc fileprivate func updateCurrentTime() {
        getCurrentTime().subscribe().disposed(by: disposeBag)
    }

    fileprivate func clear() -> Single<Void> {
        return networkRechable().flatMap { [unowned self] in
            self.evaluatePlayerCommand("clearVideo()")
        }
    }

    // In order to testing getCurrentTime & getDuration & getAvailableQualityLevels method, these are open func. Otherwise, these should be private
    // These are not chaining doOnError func, because these are using for chaining from other method
    func getCurrentTime() -> Single<Double> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommandWithResponse(command: "getCurrentTime()")
            }.do(onSuccess: { [unowned self] (currentTime: Double) in
                self.currentTime.value = CGFloat(currentTime)
            })
    }

    func getDuration() -> Single<Double> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommandWithResponse(command: "getDuration()")
            }.do(onSuccess: { [unowned self] (duration: Double) in
                print("WKWebViewPlayer - duration: \(duration)")
                self.duration.value = CGFloat(duration)
            })
    }

    func getAvailableQualityLevels() -> Single<[String]> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommandWithResponse(command: "getAvailableQualityLevels()")
            }.do(onSuccess: { [unowned self] levels in
                self.availableQualityLevels.value = levels.compactMap({ (level) -> PlayerQuality? in
                    PlayerQuality(quality: level)
                })
                if self.availableQualityLevels.value.count != 0 {
                    print("WKWebViewPlayer - get quality levels: \(self.availableQualityLevels.value)")
                }
            })
    }

    // Using skipWhile because ready will change many times when wkwebviewplayer init or reset ready value
    func loadVideoID(videoID: String) -> Single<Void> {

        return networkRechable().do(onSuccess: { [unowned self] _ in
            self.error.value = nil
            self.ready.value = false
            self.currentTime.value = 0
            self.duration.value = 0
            self.videoId = videoID
            self.loadWKWebView(self.playerVars)
        }).flatMap { [unowned self] _ in
            self.ready.asObservable()
                .timeout(5, scheduler: MainScheduler.asyncInstance)
                .skipWhile { $0 == false }
                .take(1).asSingle()
        }.flatMap { [unowned self] _ in
            self.getDuration()
        }.map { _ -> Void in
        }
            .do(onSuccess: { [unowned self] _ in
            self.state.value = .ready
        }, onError: { [unowned self] _ in
            self.error.value = .loadVideoIdError
        })
    }

    func play() -> Single<Void> {
        return networkRechable()
            .flatMap { [unowned self] in
                if self.duration.value == 0 {
                    self.getDuration().subscribe().disposed(by: self.disposeBag)
                }
                return self.evaluatePlayerCommand("playVideo()")
            }.do(onError: { [unowned self] _ in
                self.error.value = .playError
            })
    }

    func pause() -> Single<Void> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommand("pauseVideo()")
            }.do(onError: { [unowned self] _ in
                self.error.value = .pauseError
            })
    }

    func stop() -> Single<Void> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommand("stopVideo()")
            }.do(onError: { [unowned self] _ in
                self.error.value = .stopError
            })
    }

    func seekTo(time: CGFloat) -> Single<Void> {
        return networkRechable()
            .flatMap { [unowned self] in
                self.evaluatePlayerCommand("seekTo(\(time),\(true))")
            }.do(onError: { [unowned self] _ in
                self.error.value = .seekToError
            })
    }

    func setReplay(rePlay: Bool) {
        replay.value = rePlay
    }

    func setQuality(quality: PlayerQuality) -> Single<Void> {
        guard self.quality.value != quality else {
            return Single.just(())
        }
        guard availableQualityLevels.value.contains(quality) else {
            error.value = .setQualityError
            return Single.error(PlayerError.setQualityError)
        }

        return networkRechable()
            .flatMap { [unowned self] in
                self.getCurrentTime()
            }.flatMap { [unowned self] currenttime -> Single<Void> in
                self.evaluatePlayerCommand("loadVideoById({\"videoId\": \"\(self.videoId)\",\"startSeconds\":\"\(currenttime)\",\"suggestedQuality\":\"\(quality.rawValue)\"})")
            }.do(onError: { [unowned self] _ in
                self.error.value = .setQualityError
            })
    }

    func asView() -> UIView {
        return self
    }

    func evaluatePlayerCommand(_ command: String) -> Single<Void> {

        return Single<Void>.create(subscribe: { [unowned self] observer -> Disposable in

            let fullCommand = "player." + command + ";"
            self.webView.evaluateJavaScript(fullCommand, completionHandler: { _, error in
                if let nserror = error as NSError?, nserror.code == 5 {
                    observer(.success(()))
                    return
                }
                guard error == nil else {
                    let error = error! as NSError
                    print("WKWebViewPlayer - evaluatePlayerCommand error: \(String(describing: error))")
                    observer(.error(error))
                    return
                }
                observer(.success(()))
            })
            return Disposables.create()
        })
    }

    func evaluatePlayerCommandWithResponse<ResponseType>(command: String) -> Single<ResponseType> {

        return Single<ResponseType>.create(subscribe: { [unowned self] observer -> Disposable in

            let fullCommand = "player." + command + ";"
            self.webView.evaluateJavaScript(fullCommand, completionHandler: { any, error in
                guard error == nil else {
                    let error = error! as NSError
                    print("WKWebViewPlayer - evaluatePlayerCommand error: \(String(describing: error))")
                    observer(.error(error))
                    return
                }
                guard let response = any as? ResponseType else {
                    print("WKWebViewPlayer - player can not get correct response type")
                    return
                }
                observer(.success(response))
            })
            return Disposables.create()
        })
    }
    
    var isNetworkReachable = true
    
    fileprivate lazy var reachability: NetworkReachabilityManager? = {
        let reachability = NetworkReachabilityManager()
        reachability?.listener = { status in
            switch status {
            case .notReachable:
                self.isNetworkReachable = false
            case .reachable(_), .unknown:
                self.isNetworkReachable = true
            }
        }
        return reachability
    }()
    
    func networkReachable() -> Single<Void> {
        return Single<Void>.create(subscribe: { (observer) -> Disposable in
            if self.isNetworkReachable {
                observer(.success(()))
            } else {
                observer(.error(NetworkError.networkUnReachable))
            }
            return Disposables.create()
        })
    }
}

extension WKWebViewPlayer: WKScriptMessageHandler {

    func userContentController(_: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == scriptMessageName else {
            print("WKWebViewPlayer - Player received unknown message from JS. Message:\(message.name), data: \(message.body)")
            return
        }
        guard let url = URL(string: String(describing: message.body)),
            url.scheme == "ytplayer",
            let event = PlayerEvent(rawValue: url.host ?? "") else {
                print("WKWebViewPlayer - Parse player message error. Message:\(message.name), data: \(message.body)")
            return
        }
        guard let data = url.getQueryStringParameter(paramaterName: "data"), data != "null" else {
            print("WKWebViewPlayer - Player query data fail")
            return
        }

        switch event {
        case .onReady:

            ready.value = true

        case .onStateChange:
            guard let stateInt = Int(data), let playerState = PlayerState(state: stateInt) else {
                print("WKWebViewPlayer - onStateChange error, unknown data: \(data)")
                return
            }
            state.value = playerState
            print("WKWebViewPlayer - onStateChange, state: \(state.value)")

        case .onPlaybackQualityChange:
            let qualityString = String(data)
            guard let playerQuality = PlayerQuality(quality: qualityString) else {
                print("WKWebViewPlayer - onPlaybackQualityChange error, unknown data: \(data)")
                return
            }
            quality.value = playerQuality
            print("WKWebViewPlayer - onPlaybackQualityChange, quality: \(quality.value)")

        case .onPlaybackRateChange:
            guard let playerRate = NumberFormatter().number(from: data) else {
                print("WKWebViewPlayer - onPlaybackRateChange error, unknown data: \(data)")
                return
            }
            print("WKWebViewPlayer - onPlaybackRateChange, rate: \(playerRate)")

        case .onPlayerError:
            ready.value = false
            guard let errorInt = Int(data) else {
                print("WKWebViewPlayer - onPlayerError, unknown data: \(data)")
                error.value = PlayerError.webviewPlayerError(.unknown)
                return
            }
            error.value = PlayerError.webviewPlayerError(.init(errorCode: errorInt))
            print("WKWebViewPlayer - onPlayerError, error: \(String(describing: error.value))")

//            101 – The owner of the requested video does not allow it to be played in embedded players.
//            150 – This error is the same as 101. It's just a 101 error in disguise!
        }
    }
}

private extension URL {

    func getQueryStringParameter(paramaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == paramaterName })?.value
    }
}
