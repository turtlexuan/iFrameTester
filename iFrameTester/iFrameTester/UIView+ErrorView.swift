//
// Created by drain on 20/04/2017.
// Copyright (c) 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit

typealias RefreshHandler = () -> Void

protocol ErrorContentView {
//    var superview: UIView? { get }
    static func newInstance(with error: Error, refreshHandler: @escaping RefreshHandler) -> ErrorContentView & UIView
    func layoutOut(on superView: UIView, withPadding: UIEdgeInsets)
}

protocol ErrorStatusView: class {
    var isShowingError: Bool { get }
    var errorView: (ErrorContentView & UIView)? { get set }
    func showErrorView(withError error: Error,
                       topPadding: CGFloat,
                       errorViewType: ErrorViewType,
                       refreshHandler: @escaping RefreshHandler)
    func dismissErrorView()
}

extension ErrorStatusView {

    var errorView: (ErrorContentView & UIView)? {
        get {
            return objc_getAssociatedObject(self, &ErrorViewKey) as? (ErrorContentView & UIView)
        }
        set {
            objc_setAssociatedObject(self,
                                     &ErrorViewKey,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var isShowingError: Bool {
        return errorView != nil
    }
}

enum ErrorViewType {
    case networkError
    case partial
    case wholeView
}

private var ErrorViewKey: Void?
extension UIView: ErrorStatusView {

    func showErrorView(withError error: Error,
                       topPadding: CGFloat = 0,
                       errorViewType: ErrorViewType,
                       refreshHandler: @escaping RefreshHandler = {}) {
        guard errorView?.superview == nil else {
            return
        }

        let contentViewType = errorViewClassFrom(type: errorViewType)
        let errorContentView = contentViewType.newInstance(with: error, refreshHandler: refreshHandler)
        errorContentView.layoutOut(on: self, withPadding: UIEdgeInsets(top: topPadding, left: 0, bottom: 0, right: 0))
        errorView = errorContentView
    }

    private func errorViewClassFrom(type: ErrorViewType) -> ErrorContentView.Type {
        switch type {
        case .networkError:
            return NetworkErrorIndicator.self
        case .wholeView:
            return WholeNoContentView.self
        case .partial:
            return PartialNoContentView.self
        }
    }

    func dismissErrorView() {
        errorView?.removeFromSuperview()
        errorView = nil
    }
}
