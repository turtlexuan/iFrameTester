//
//  RxExtensions.swift
//  VoiceTube_iOS
//
//  Created by drain on 16/08/2017.
//  Copyright © 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    public var isVisible: Binder<Bool> {
        return Binder(base) {
            view, hidden in
            view.isHidden = !hidden
        }
    }
}

extension UIControl {
    func toSelectedDriver() -> Driver<Bool> {
        return rx.controlEvent(.touchUpInside)
            .asDriver()
            .map { !self.isSelected }
    }
}

extension Reactive where Base: UISlider {
    var progress: Binder<CGFloat> {
        return Binder(base) { slider, result in
            slider.setValue(Float(result), animated: true)
        }
    }
}

extension Reactive where Base: UIProgressView {
    var progress: Binder<CGFloat> {
        return Binder(base) { progressView, result in
            progressView.setProgress(Float(result), animated: true)
        }
    }
}
