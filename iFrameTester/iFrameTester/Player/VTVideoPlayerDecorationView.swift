//
//  VTPlayerDecorationView.swift
//  VoiceTube_iOS
//
//  Created by drain on 28/07/2017.
//  Copyright © 2017 VoiceTube. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol VTVideoPlayerDecorationViewProtocol:class {
    func configure(withPlayerView playerView: VTPlayerView)
    var playerInputs: [VTPlayerViewInput] { get }
    var playerInset: UIEdgeInsets { get }
    func asView() -> UIView
}

extension VTVideoPlayerDecorationViewProtocol where Self: UIView {
    func asView() -> UIView {
        return self
    }
}

class VTVideoPlayerDecorationView: UIView, VTVideoPlayerDecorationViewProtocol {

    deinit {
        removeGestureRecognizer(tapGestureRecognizer)
    }

    private let disposeBag = DisposeBag()

    public lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "playerPlayButton"), for: .normal)
        button.setImage(UIImage(named: "playerPauseButton"), for: .selected)
        return button
    }()

    public let progressSlider = VTPlayerProgressSlider()

    public lazy var currentTimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .vtWhite
        label.font = .vtDuration13PtFont()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    public lazy var durationLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .vtWhite
        label.font = .vtDuration13PtFont()
        return label
    }()

    public lazy var fullScreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "fullScreenButton"), for: .normal)
        return button
    }()
    
    public lazy var bottomShadowView: UIImageView = {
        let img = UIImage(named: "playerViewBottomShadow")!
        let resizedImg = img.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: img.size.width, right: img.size.height), resizingMode: .tile).resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: img.size.height), resizingMode: .stretch)
        let view = UIImageView(image: resizedImg)
        return view
    }()
    
    public lazy var fullScreenButtonTap: Driver<Void> = {
        self.fullScreenButton.rx.controlEvent(.touchUpInside).asDriver()
    }()

    public let showControlSubject = PublishSubject<Bool>()

    // Bool means show or hide the control
    public let tappedSubject = BehaviorSubject<Bool>(value: true)

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
    }()

    var controlConstraints = [NSLayoutConstraint]()

    init(_ showFullScreenButton: Bool = true) {
        super.init(frame: .zero)
        
        addSubview(bottomShadowView)
        addSubview(playPauseButton)
        addSubview(currentTimeLabel)
        addSubview(durationLabel)
        addSubview(progressSlider)
        
        controlConstraints.append(contentsOf: playPauseButton.autoCenterInSuperview())
        controlConstraints.append(contentsOf: [
            bottomShadowView.autoPinEdge(toSuperviewEdge: .leading),
            bottomShadowView.autoPinEdge(toSuperviewEdge: .trailing),
            bottomShadowView.autoPinEdge(toSuperviewEdge: .bottom),
            bottomShadowView.autoSetDimension(.height, toSize: 36),
            
            progressSlider.autoSetDimension(.height, toSize: 20),
            progressSlider.autoPinEdge(toSuperviewEdge: .leading),
            progressSlider.autoPinEdge(toSuperviewEdge: .trailing),
            progressSlider.autoPinEdge(toSuperviewEdge: .bottom),

            currentTimeLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 8),
            currentTimeLabel.autoPinEdge(.bottom, to: .top, of: progressSlider, withOffset: 4),

            durationLabel.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),
            durationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8),
        ])

        addGestureRecognizer(tapGestureRecognizer)

        tappedSubject
            .flatMapLatest { [weak self] show -> Single<Bool> in
                guard let `self` = self else {
                    return Single.error(NSError())
                }
                return !show ?
                    self.hideControls() :
                    self.showControls()
                    .delay(3, scheduler: MainScheduler.instance)
                    .flatMap { [weak self] _ in
                        guard let `self` = self else {
                            return Single.error(NSError())
                        }
                        return self.hideControls()
                    }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private var isShowingControl = true

    @objc internal func onViewTapped() {
        tappedSubject.onNext(!isShowingControl)
    }

    private func showControls() -> Single<Bool> {
        showControlSubject.onNext(true)
        guard isShowingControl == false else {
            return Single.just(true)
        }
        isShowingControl = true
        return
            animate(withDuration: 0.3) {
                self.bottomShadowView.isHidden = false
                self.playPauseButton.isHidden = false
                self.currentTimeLabel.isHidden = false
                self.durationLabel.isHidden = false
                self.progressSlider.isHidden = false
                self.bottomShadowView.alpha = 1
                self.playPauseButton.alpha = 1
                self.currentTimeLabel.alpha = 1
                self.durationLabel.alpha = 1
                self.progressSlider.alpha = 1
                self.progressSlider.showControlIndicator = true
            }
    }

    private func hideControls() -> Single<Bool> {
        showControlSubject.onNext(false)
        guard isShowingControl else {
            return Single.just(true)
        }
        isShowingControl = false
        return animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.progressSlider.showControlIndicator = false
            self.bottomShadowView.alpha = 0
            self.playPauseButton.alpha = 0
            self.currentTimeLabel.alpha = 0
            self.durationLabel.alpha = 0
            self.progressSlider.alpha = 0
            }.do(onSuccess: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            self.bottomShadowView.isHidden = true
            self.playPauseButton.isHidden = true
            self.currentTimeLabel.isHidden = true
            self.durationLabel.isHidden = true
            self.progressSlider.isHidden = true
        })
    }

    func configure(withPlayerView playerView: VTPlayerView) {
        playerView
            .currentTime
            .map { [weak self] currentTime in
                guard let `self` = self else { return "" }
                return self.secondsToClockTime(currentTime)
            }
            .drive(currentTimeLabel.rx.text)
            .disposed(by: disposeBag)

        playerView
            .duration
            .distinctUntilChanged()
            .map { [weak self] currentTime in
                guard let `self` = self else { return "" }
                return self.secondsToClockTime(currentTime)
            }
            .drive(durationLabel.rx.text)
            .disposed(by: disposeBag)

        playerView
            .currentProgress
            .drive(progressSlider.rx.progress)
            .disposed(by: disposeBag)

        playerView
            .state
            .map { $0 == .playing }
            .drive(playPauseButton.rx.isSelected)
            .disposed(by: disposeBag)
    }

    var playerInset: UIEdgeInsets = .zero

    lazy var playerInputs: [VTPlayerViewInput] = {
        let sliderDriver =
            self.progressSlider.rx.value
            .asDriver()
            .skip(1) // Skip when slider initialization emit a default value
            .do(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                self.tappedSubject.onNext(true)
            })
            .map { CGFloat($0) }
        
        let playPauseDriver =
            self.playPauseButton.rx.controlEvent(.touchUpInside)
            .asDriver()
            .map { [weak self] _ -> Bool in
                guard let `self` = self else { return false }
                return !self.playPauseButton.isSelected
            }

        Driver.zip(sliderDriver, playPauseDriver) { _, _ in true }
            .drive(self.tappedSubject)
            .disposed(by: self.disposeBag)

        return [
            .progress(sliderDriver),
            .playButtonTaps(playPauseDriver),
        ]
    }()

    func secondsToClockTime(_ seconds: CGFloat) -> String {
        let intValue = Int(seconds)
        return String(format: "%.2d:%.2d",
                      intValue / 60,
                      intValue % 60)
    }

    required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }
}

class VTVideoControllerDecorationView: UIView, VTVideoPlayerDecorationViewProtocol {

    private let disposeBag = DisposeBag()

    func configure(withPlayerView playerView: VTPlayerView) {
        vtDecorationView.configure(withPlayerView: playerView)
    }

    lazy var playerInputs: [VTPlayerViewInput] = {
        self.vtDecorationView.playerInputs
    }()

    lazy var playerInset: UIEdgeInsets = {
        self.vtDecorationView.playerInset
    }()

    let repeatSentenceButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "fullScreenRepeatIcon")?.image(alpha: 0.3), for: .normal)
        button.setImage(UIImage(named: "fullScreenRepeatIcon"), for: .selected)
        return button
    }()

    let showCaptionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "fullScreenCaptionIcon")?.image(alpha: 0.3), for: .normal)
        button.setImage(UIImage(named: "fullScreenCaptionIcon"), for: .selected)
        return button
    }()

    private let captionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(white: 255.0 / 255.0, alpha: 1.0)
        label.numberOfLines = 0
        return label
    }()

    private let vtDecorationView = VTVideoPlayerDecorationView()

    public var captionText: Driver<String>? {
        didSet {
            if let captionText = captionText {
                captionText
                    .drive(captionLabel.rx.text)
                    .disposed(by: disposeBag)
            }
        }
    }
 
    public lazy var progressSlider = {
        self.vtDecorationView.progressSlider
    }()
    
    public lazy var showControlSubject = {
        self.vtDecorationView.showControlSubject
    }()

    public lazy var fullScreenButtonTap: Driver<Void> = {
        self.vtDecorationView.fullScreenButtonTap
    }()

    private let enableRepeatSentence: Driver<Bool>

    lazy var fullScreenConstraints: [NSLayoutConstraint] = {
        var fullScreenConstraints = [NSLayoutConstraint]()
        let bottomShadow = self.vtDecorationView.bottomShadowView
        let playPauseButton = self.vtDecorationView.playPauseButton
        let currentTimeLabel = self.vtDecorationView.currentTimeLabel
//        let fullScreenButton = UIButton()
        let durationLabel = self.vtDecorationView.durationLabel
        let progressSlider = self.vtDecorationView.progressSlider

//        fullScreenButton.setImage(UIImage(named: "fullScreenButtonSelected"), for: .selected)

        progressSlider.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        
        fullScreenConstraints.append(contentsOf: bottomShadow.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top))
        fullScreenConstraints.append(bottomShadow.autoSetDimension(.height, toSize: 46))
        fullScreenConstraints.append(contentsOf: playPauseButton.autoCenterInSuperview())
        fullScreenConstraints.append(contentsOf: [
            currentTimeLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 24),
            currentTimeLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 24),

//            fullScreenButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 24),
//            fullScreenButton.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),

            durationLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: -24),
//            durationLabel.autoPinEdge(.trailing,
//                                      to: .leading,
//                                      of: fullScreenButton,
//                                      withOffset: -24),
            durationLabel.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),

            self.showCaptionButton.autoPinEdge(.trailing,
                                               to: .leading,
                                               of: durationLabel,
                                               withOffset: -24),
            self.showCaptionButton.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),

            self.repeatSentenceButton.autoPinEdge(.trailing,
                                                  to: .leading,
                                                  of: self.showCaptionButton,
                                                  withOffset: -24),
            self.repeatSentenceButton.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),

            progressSlider.autoPinEdge(.leading,
                                       to: .trailing,
                                       of: currentTimeLabel,
                                       withOffset: 24),
            progressSlider.autoPinEdge(.trailing,
                                       to: .leading,
                                       of: self.repeatSentenceButton,
                                       withOffset: -24),
            progressSlider.autoAlignAxis(.horizontal, toSameAxisOf: currentTimeLabel),
            self.captionLabel.autoAlignAxis(.vertical, toSameAxisOf: self.vtDecorationView),
            self.captionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual),
            self.captionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual),
            self.captionLabel.autoPinEdge(.bottom, to: .top, of: self.vtDecorationView.progressSlider, withOffset: -16),
        ])
        return fullScreenConstraints
    }()

    init(enableShowCaption: Variable<Bool>,
         enableRepeatSentence: Variable<Bool>,
         showFullScreenControl: Variable<Bool>) {
        self.enableRepeatSentence = enableRepeatSentence.asDriver()
        super.init(frame: .zero)
        addSubview(vtDecorationView)
        vtDecorationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        enableShowCaption.asDriver()
            .drive(captionLabel.rx.isVisible)
            .disposed(by: disposeBag)

        enableShowCaption.asDriver()
            .drive(showCaptionButton.rx.isSelected)
            .disposed(by: disposeBag)
        showCaptionButton.toSelectedDriver()
            .drive(enableShowCaption)
            .disposed(by: disposeBag)

        enableRepeatSentence.asDriver()
            .drive(repeatSentenceButton.rx.isSelected)
            .disposed(by: disposeBag)
        repeatSentenceButton.toSelectedDriver()
            .drive(enableRepeatSentence)
            .disposed(by: disposeBag)

        let showFullScreenControlDriver = showFullScreenControl.asDriver()

        let showDriver =
            Driver.combineLatest(
                showFullScreenControlDriver,
                vtDecorationView.showControlSubject
                    .asDriver(onErrorJustReturn: false)
                    .startWith(false)
            ) { $0 && $1 }

        showDriver
            .drive(showCaptionButton.rx.isVisible)
            .disposed(by: disposeBag)

        showDriver
            .drive(repeatSentenceButton.rx.isVisible)
            .disposed(by: disposeBag)

        vtDecorationView.addSubview(repeatSentenceButton)
        vtDecorationView.addSubview(showCaptionButton)
        vtDecorationView.addSubview(captionLabel)
        fullScreenConstraints.forEach { $0.isActive = false }

        captionLabel.backgroundColor = UIColor(red: 43.0 / 255.0, green: 43.0 / 255.0, blue: 43.0 / 255.0, alpha: 1.0)
        vtDecorationView.controlConstraints.append(contentsOf: [
            self.captionLabel.autoAlignAxis(.vertical, toSameAxisOf: self.vtDecorationView),
            self.captionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual),
            self.captionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual),
            self.captionLabel.autoPinEdge(.bottom, to: .top, of: self.vtDecorationView.progressSlider, withOffset: -4),
        ])

        showFullScreenControlDriver.drive(onNext: { [weak self] show in
            guard let `self` = self else {
                return
            }
            if show {
                if self.repeatSentenceButton.superview == nil {
                    self.vtDecorationView.addSubview(self.repeatSentenceButton)
                }
                if self.showCaptionButton.superview == nil {
                    self.vtDecorationView.addSubview(self.showCaptionButton)
                }
                self.vtDecorationView.controlConstraints.forEach { $0.isActive = false }
                self.fullScreenConstraints.forEach { $0.isActive = true }
            } else {
                if self.repeatSentenceButton.superview != nil {
                    self.repeatSentenceButton.removeFromSuperview()
                }
                if self.showCaptionButton.superview != nil {
                    self.showCaptionButton.removeFromSuperview()
                }
                self.fullScreenConstraints.forEach { $0.isActive = false }
                self.vtDecorationView.controlConstraints.forEach { $0.isActive = true }
            }
        }).disposed(by: disposeBag)
//        showFullScreenControlDriver
//            .drive(vtDecorationView.fullScreenButton.rx.isSelected)
//            .disposed(by: disposeBag)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
