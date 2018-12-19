//
// Created by drain on 26/05/2017.
// Copyright (c) 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit

class NetworkErrorIndicator: UIView, ErrorContentView {

    lazy var titleLabel: UILabel = {
        let label = UILabel.newAutoLayout()
        label.textColor = UIColor.vtWhite
        label.font = UIFont.vtDuration13PtFont()
        return label
    }()

    static func newInstance(with error: Error, refreshHandler: @escaping RefreshHandler) -> ErrorContentView & UIView {
        return NetworkErrorIndicator(with: error, refreshHandler: refreshHandler)
    }

    init(with _: Error, refreshHandler _: @escaping RefreshHandler) {
        super.init(frame: CGRect.zero)
        addSubview(titleLabel)
        titleLabel.text = "Unable to connect to server"
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16, relation: .greaterThanOrEqual)
        titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)

        backgroundColor = UIColor(white: 0.0, alpha: 0.81)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutOut(on superView: UIView, withPadding: UIEdgeInsets) {
        superView.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: withPadding)
    }
}
