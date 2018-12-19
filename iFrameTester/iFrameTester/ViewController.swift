//
//  ViewController.swift
//  iFrameTester
//
//  Created by 劉仲軒 on 2018/12/18.
//  Copyright © 2018 劉仲軒. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let playerHeight = AppDelegate.ScreenWidth * 9 / 16
    
    lazy var decorationView: VTVideoControllerDecorationView = {
        let view =
            VTVideoControllerDecorationView(enableShowCaption: Variable<Bool>(false),
                                            enableRepeatSentence: Variable<Bool>(false),
                                            showFullScreenControl: Variable<Bool>(false))
        return view
    }()
    
    lazy var vtPlayer: VTPlayerViewProtocol = {
        return VTPlayerView(inputs: [
            .second(self.secondsSubject.asDriver(onErrorJustReturn: 0)),
            ],
                            decorationView: self.decorationView)
    }()
    
    lazy var secondsSubject: PublishSubject<CGFloat> = {
        let subject = PublishSubject<CGFloat>()
        return subject
    }()
    
    lazy var youtubeIdTextField: UITextField = {
        let textfield = UITextField()
        textfield.placeholder = "Enter YouTube ID"
        textfield.font = UIFont.vtBody14PtFont()
        textfield.textColor = UIColor.vtTextGrey
        textfield.textAlignment = .center
        textfield.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        textfield.applyUnderLineStyle(withBottomPadding: 1, lineColor: UIColor.vtTextGrey)
        return textfield
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Submit", for: .normal)
        return button
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Launched")
        
        submitButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [weak self] (_) in
            guard let `self` = self else { return }
            if let id = self.youtubeIdTextField.text {
                self.playerReload(id: id)
                self.view.endEditing(true)
            }
        }).disposed(by: disposeBag)
    }
    
    override func loadView() {
        super.loadView()
        
        let vtPlayerController = vtPlayer.asViewController()
        addChild(vtPlayerController)
        view.addSubview(vtPlayerController.view)
        vtPlayerController.willMove(toParent: self)
        vtPlayerController.didMove(toParent: self)
        
        view.addSubview(youtubeIdTextField)
        view.addSubview(submitButton)
        
        vtPlayerController.view.snp.makeConstraints { (make) in
            make.height.equalTo(playerHeight)
            make.top.equalToSuperview().inset(AppDelegate.StatusBarHeight)
            make.right.left.equalToSuperview()
        }
        
        youtubeIdTextField.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 200, height: 40))
            make.top.equalTo(vtPlayerController.view.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        submitButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 150, height: 42))
            make.centerX.equalToSuperview()
            make.top.equalTo(youtubeIdTextField.snp.bottom).offset(10)
        }
        submitButton.applyGradientStyle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func playerReload(id: String) {
        vtPlayer.loadVideoId(videoId: id, autoPlay: true)
    }
}

