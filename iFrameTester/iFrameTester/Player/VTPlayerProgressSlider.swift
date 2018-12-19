//
//  VTPlayerProgressSlider.swift
//  VoiceTube_iOS
//
//  Created by drain on 31/07/2017.
//  Copyright © 2017 VoiceTube. All rights reserved.
//

import Foundation
import UIKit

class VTPlayerProgressSlider: UISlider {

    private var sliderBounds: CGRect = .zero

    private var thumbImage: UIImage?
    
    var thumbColor: UIColor

    required init?(coder _: NSCoder) {
        fatalError("not implemented")
    }

    init(thumbColor: UIColor = .white) {
        self.thumbColor = thumbColor
        super.init(frame: .zero)
    }

    public var showControlIndicator = true {
        didSet {
            if showControlIndicator && !hideControlIndicator {
                setThumbImage(thumbImage, for: .normal)
            } else {
                setThumbImage(UIImage(), for: .normal)
            }
        }
    }
    
    public var hideControlIndicator = false
    
    func setupRange(minimumValue: CGFloat, maximumValue: CGFloat) {
        self.minimumValue = Float(minimumValue)
        self.maximumValue = Float(maximumValue)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds != sliderBounds {
            sliderBounds = bounds
            let gradiendImage = UIImage.mainGradient(frame: CGRect(x: 0, y: 0, width: sliderBounds.width, height: 10))
            setMinimumTrackImage(gradiendImage.resizableImage(withCapInsets: .zero), for: .normal)

            thumbImage = UIImage.circle(fromColor: thumbColor, size: CGSize(width: 10, height: 10))
            
            setThumbImage(thumbImage, for: .normal)
            if showControlIndicator {
                setThumbImage(thumbImage, for: .normal)
            } else {
                setThumbImage(UIImage(), for: .normal)
            }
            
            let bigThumbImage = UIImage.circle(fromColor: thumbColor, size: CGSize(width: 20, height: 20))

            setThumbImage(bigThumbImage, for: .highlighted)
        }
    }
}
