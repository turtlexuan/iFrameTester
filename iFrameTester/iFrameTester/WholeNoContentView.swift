//
// Created by drain on 26/05/2017.
// Copyright (c) 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class WholeNoContentView: UIView, ErrorContentView {

    let refreshHandler: RefreshHandler

    private var currentRetryButtonBounds = CGRect.zero

    lazy var errorImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon_no_content"))
        imageView.contentMode = .center
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label: UILabel = .newAutoLayout()
        label.textColor = .vtTextGrey
        label.font = .vtTitle17PtFont()
        return label
    }()

    lazy var retryButton: UIButton = {
        let button: UIButton = UIButton.newAutoLayout()

        let refreshImage = UIImage(named: "icon_retry_arrow_white")!
        button.setTitle("Retry", for: .normal)
        button.titleLabel?.font = .vtTitle17PtFont()
        button.setTitleColor(.white, for: .normal)
        button.setImage(refreshImage, for: .normal)
        button.swapTextAndImage(spacing: 4)
        button.addTarget(self, action: #selector(onRefresh), for: .touchUpInside)
        return button
    }()

    static func newInstance(with error: Error, refreshHandler: @escaping RefreshHandler) -> ErrorContentView & UIView {
        return WholeNoContentView(with: error, refreshHandler: refreshHandler)
    }

    init(with _: Error, refreshHandler: @escaping RefreshHandler) {
        self.refreshHandler = refreshHandler
        super.init(frame: CGRect.zero)
        titleLabel.text = "Unable to connect to server"

        let container = UIView()

        addSubview(container)
        container.addSubview(errorImage)
        container.addSubview(titleLabel)
        container.addSubview(retryButton)

        errorImage.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)

        titleLabel.autoPinEdge(.top, to: .bottom, of: errorImage, withOffset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleLabel.autoPinEdge(.bottom, to: .top, of: retryButton, withOffset: -16)

        retryButton.autoPinEdge(toSuperviewEdge: .bottom)
        retryButton.autoAlignAxis(toSuperviewAxis: .vertical)

        retryButton.applyGradientStyle()

        container.autoPinEdgesToSuperviewEdges()
        backgroundColor = .vtBgWhite
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onRefresh(_: UIButton) {
        refreshHandler()
    }

    func layoutOut(on superView: UIView, withPadding padding: UIEdgeInsets) {
        superView.addSubview(self)

        if padding.top == 0 {
            autoCenterInSuperview()
        } else {
            autoPinEdge(toSuperviewEdge: .top, withInset: padding.top)
            autoAlignAxis(toSuperviewAxis: .vertical)
        }
    }
}
