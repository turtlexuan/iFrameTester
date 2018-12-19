//
// Created by drain on 26/05/2017.
// Copyright (c) 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit

class PartialNoContentView: UIView, ErrorContentView {

    let refreshHandler: RefreshHandler

    lazy var titleLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.textColor = UIColor.vtTextGrey
        label.font = UIFont.vtBody14PtFont()
        return label
    }()

    lazy var retryButton: UIButton = {
        let button = UIButton.newAutoLayout()
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(UIColor.vtMainBlue, for: .normal)
        button.titleLabel?.font = UIFont.vtTitle17PtFont()
        button.setImage(UIImage(named: "icon_retry_arrow_blue"), for: .normal)
        button.swapTextAndImage(spacing: 4)
        button.applyGradientStroke()
        button.addTarget(self, action: #selector(onRefresh(_:)), for: .touchUpInside)
        return button
    }()

    static func newInstance(with error: Error, refreshHandler: @escaping RefreshHandler) -> ErrorContentView & UIView {
        return PartialNoContentView(with: error, refreshHandler: refreshHandler)
    }

    init(with _: Error, refreshHandler: @escaping RefreshHandler) {
        self.refreshHandler = refreshHandler
        super.init(frame: CGRect.zero)
        titleLabel.text = "Unable to connect to server"
        let container = UIView()
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(retryButton)

        titleLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .trailing)
        retryButton.autoPinEdges(toSuperviewMarginsExcludingEdge: .leading)
        retryButton.autoPinEdge(.leading, to: .trailing, of: titleLabel, withOffset: 16)

        container.autoCenterInSuperview()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onRefresh(_: UIButton) {
        refreshHandler()
    }

    func layoutOut(on superView: UIView, withPadding: UIEdgeInsets) {
        superView.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: withPadding)
    }
}
