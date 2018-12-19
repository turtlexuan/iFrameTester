//
//  VTPlayerView.swift
//  VoiceTube_iOS
//
//  Created by drain on 20/07/2017.
//  Copyright © 2017 VoiceTube. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import RxCocoa

enum VTPlayerViewInput {
    case progress(_: Driver<CGFloat>)
    case second(_: Driver<CGFloat>)
    case isRepeatSentence(_: Driver<Bool>)
    case playButtonTaps(_: Driver<Bool>)
    case videoQuality(_: Driver<PlayerQuality>)
    case autoReplay(_: Driver<Bool>)
}

protocol VTPlayerViewProtocol {

    init(withPlayer player: WKWebViewPlayerProtocol,
         inputs: [VTPlayerViewInput],
         decorationView: VTVideoPlayerDecorationViewProtocol)

    var currentTime: Driver<CGFloat> { get }
    var currentProgress: Driver<CGFloat> { get }
    var duration: Driver<CGFloat> { get }
    var availableQualityLevels: Variable<[PlayerQuality]> { get }
    var quality: Variable<PlayerQuality> { get }
    var error: Driver<PlayerError?> { get }
    var state: Driver<PlayerState> { get }

    var captionTimes: [CaptionTime]? { get set }
    var currentCaptionIndex: Driver<(Int, CaptionTime)> { get }
    var currentIndexAndTime: Variable<(Int, CaptionTime)> { get }
    var repeatCaptionTimeIndex: Variable<CaptionTime?> { get set }

    func asViewController() -> UIViewController
    func loadVideoId(videoId: String, autoPlay: Bool)
    func loadVideoId(videoId: String)
    func repeatCurrentSentence()
    func playVideo()
    func pauseVideo()
    func setQuality(quality: PlayerQuality) -> Single<Void>
    func getDuration() -> CGFloat
    func getState() -> PlayerState
    func showErrorView(error: Error, refreshHandler: @escaping RefreshHandler)
    func dismissErrorView()
}

extension VTPlayerViewProtocol where Self: UIViewController {
    func asViewController() -> UIViewController {
        return self
    }
}

class VTPlayerView: UIViewController, VTPlayerViewProtocol {

    private let disposeBag = DisposeBag()

    private let player: WKWebViewPlayerProtocol

    private var videoID: String = ""

    private let inputs: [VTPlayerViewInput]

    private var videoCaptionTimeCollection: CaptionTimeCollection?

    var repeatCaptionTimeIndex: Variable<CaptionTime?> = Variable(nil)

    private unowned let decorationView: VTVideoPlayerDecorationViewProtocol

    deinit {
        player.removeScriptHandler()
    }
    
    required init(
        withPlayer player: WKWebViewPlayerProtocol = WKWebViewPlayer(frame: .zero),
        inputs: [VTPlayerViewInput] = [VTPlayerViewInput](),
        decorationView: VTVideoPlayerDecorationViewProtocol = VTVideoPlayerDecorationView()) {
        self.player = player
        self.inputs = inputs
        self.decorationView = decorationView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }

    public lazy var error: Driver<PlayerError?> = {
        self.player.error.asDriver()
    }()

    public lazy var availableQualityLevels: Variable<[PlayerQuality]> = {
        self.player.availableQualityLevels
    }()

    public lazy var quality: Variable<PlayerQuality> = {
        self.player.quality
    }()

    public lazy var duration: Driver<CGFloat> = {
        self.player.duration.asDriver()
    }()

    public lazy var state: Driver<PlayerState> = {
        self.player.state.asDriver()
    }()

    public lazy var currentProgress: Driver<CGFloat> = {
        Driver.combineLatest(self.player.duration.asDriver(), self.currentTime) {
            (duration, currentTime) -> CGFloat in
            duration <= 0 ? 0 : currentTime / duration
        }
    }()

    public lazy var currentCaptionIndex: Driver<(Int, CaptionTime)> = {
        guard let videoCaptionTimeCollection = self.videoCaptionTimeCollection else {
            fatalError("videoCaptionTime indexes should set before subscribes to currentCaptionIndex")
        }
        return videoCaptionTimeCollection.currentIndexAndTime.asDriver()
    }()
    
    public var currentIndexAndTime: Variable<(Int, CaptionTime)> {
        guard let videoCaptionTimeCollection = self.videoCaptionTimeCollection else {
            fatalError("videoCaptionTime indexes should set before subscribes to currentCaptionIndex")
        }
        return videoCaptionTimeCollection.currentIndexAndTime
    }

    public lazy var currentTime: Driver<CGFloat> = {
        self.player
            .currentTime
            .asObservable()
            .flatMapFirst({ [unowned self] time -> Observable<CGFloat> in
                return
                    self.doControlActionIfRequired(withCurrentTime: time)
                    .asObservable()
                    .filter { !$0 }
                    .map { _ in time }
            }).asDriver(onErrorRecover: { _ -> Driver<CGFloat> in
                Driver.never()
            })
    }()

    public var captionTimes: [CaptionTime]? {
        didSet {
            self.videoCaptionTimeCollection =
                CaptionTimeCollection(withTimeDriver: self.currentTime, captionTimes: captionTimes!)
        }
    }

    override func loadView() {
        super.loadView()

        let playerView = player.asView()
        view.addSubview(playerView)

        let inset = self.decorationView.playerInset
        playerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(inset)
        }

        let decorationView = self.decorationView.asView()
        view.addSubview(decorationView)
        decorationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func loadVideoId(videoId: String, autoPlay: Bool = true) {
        videoID = videoId
        player
            .loadVideoID(videoID: videoID)
            .flatMap({ (_) -> Single<Void> in
                if autoPlay {
                    return self.player.play()
                } else {
                    return Single.just(())
                }
            })
            .subscribe()
            .disposed(by: disposeBag)

        let decorationView = self.decorationView
        decorationView.configure(withPlayerView: self)
        configure(inputs: decorationView.playerInputs)

        configure(inputs: inputs)
    }
    
    // For Pro PreCheck Video
    public func loadVideoId(videoId: String) {
        videoID = videoId
        player
            .loadVideoID(videoID: videoID)
            .flatMap({ (_) -> Single<Void> in
                return self.player.play()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func configure(inputs: [VTPlayerViewInput]) {
        for input in inputs {
            switch input {
            case let .progress(driver):
                driver
                    .map({ [unowned self] progress -> CGFloat in
                        return self.player.duration.value * progress
                    })
                    .flatMapLatest({ [unowned self] time -> Driver<Void> in
                        return self.player.seekTo(time: time).asDriver(onErrorJustReturn: ())
                    })
                    .drive()
                    .disposed(by: disposeBag)
            case let .isRepeatSentence(driver):
                driver
                    .map({ [unowned self] on -> CaptionTime? in
                        on ? self.videoCaptionTimeCollection?.currentIndexAndTime.value.1 : nil
                    })
                    .drive(repeatCaptionTimeIndex)
                    .disposed(by: disposeBag)
            case let .playButtonTaps(driver):
                driver
                    .flatMapLatest { [unowned self] play -> Driver<Void> in
                        return play ?
                            self.player.play().asDriver(onErrorJustReturn: ()) :
                            self.player.pause().asDriver(onErrorJustReturn: ())
                    }
                    .drive()
                    .disposed(by: disposeBag)
            case let .videoQuality(driver):
                driver
                    .flatMapLatest({ [unowned self] quality -> Driver<Void> in
                        return self.player.setQuality(quality: quality).asDriver(onErrorJustReturn: ())
                    })
                    .drive()
                    .disposed(by: disposeBag)
            case let .autoReplay(driver):
                driver
                    .drive(onNext: { [unowned self] on in
                        self.player.setReplay(rePlay: on)
                    })
                    .disposed(by: disposeBag)
            case let .second(driver):
                driver
                    .do(onNext: { [unowned self] time in
                        if self.repeatCaptionTimeIndex.value != nil,
                            let collection = self.videoCaptionTimeCollection {
                            // + 0.1 is avoiding the time between two captionTime's range
                            let nextIndex = collection.findIndex(withTime: time + 0.1, currentIndex: collection.currentIndexAndTime.value.0)
                            if let nextPausedCaptionTime = self.captionTimes?[nextIndex] {
                                self.repeatCaptionTimeIndex.value = nextPausedCaptionTime
                            }
                        }
                    })
                    .flatMapLatest({ [unowned self] time -> Driver<Void> in
                        return self.player.seekTo(time: time).asDriver(onErrorJustReturn: ())
                    })
                    .flatMap({ [unowned self] (_) -> Driver<Void> in
                        return self.player.play().asDriver(onErrorJustReturn: ())
                    })
                    .drive()
                    .disposed(by: disposeBag)
            }
        }
    }

    /*
     method for handling seek control when specific time
     return Single<true> means has done control event, false means no control event happenned
     */
    private func doControlActionIfRequired(withCurrentTime time: CGFloat) -> Single<Bool> {
        if let repeatIndex = self.repeatCaptionTimeIndex.value {
            if time < repeatIndex.startTime || time > repeatIndex.endTime {
                return player
                    .seekTo(time: repeatIndex.startTime)
                    .map { true }
            }
        }
        return Single.just(false)
    }

    public func repeatCurrentSentence() {
        if let captionIndex = videoCaptionTimeCollection?.currentIndexAndTime.value.1 {
            repeatCaptionTimeIndex.value = captionIndex
        } else {
            print("repeatCurrentSentence fail !!")
        }
    }
    
    public func setQuality(quality: PlayerQuality) -> Single<Void> {
        return player.setQuality(quality: quality)
    }

    public func getDuration() -> CGFloat {
        return player.duration.value
    }
    
    public func playVideo() {
        player.play().subscribe().disposed(by: disposeBag)
    }

    public func pauseVideo() {
        player.pause().subscribe().disposed(by: disposeBag)
    }
    
    public func getState() -> PlayerState {
        return player.state.value
    }

    public func showErrorView(error: Error, refreshHandler: @escaping RefreshHandler) {
        player.pause().subscribe().disposed(by: disposeBag)
        view.showErrorView(withError: error, errorViewType: .partial, refreshHandler: refreshHandler)
        player.asView().alpha = 0
        decorationView.asView().alpha = 0
    }

    public func dismissErrorView() {
        decorationView.asView().alpha = 1
        player.asView().alpha = 1
        view.dismissErrorView()
    }
}
