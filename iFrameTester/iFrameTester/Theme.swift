//
//  Theme.swift
//  VoiceTube_iOS
//
//  Created by TsauPoPo on 2017/4/27.
//  Copyright © 2017年 VoiceTube. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static func cornerRadius() -> CGFloat {
        return 4.0
    }

    static func setNavigationBarTintColor() {
        UINavigationBar.appearance().tintColor = UIColor.black
    }
}

extension UIColor {
    class var vtGradientBlue: UIColor {
        return UIColor(red: 41.0 / 255.0, green: 180.0 / 255.0, blue: 242.0 / 255.0, alpha: 1.0)
    }
}

// Color palette with Zeplin

extension UIColor {
    class var vtWhite: UIColor {
        return UIColor(white: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var vtGradientPurple: UIColor {
        return UIColor(red: 92.0 / 255.0, green: 76.0 / 255.0, blue: 212.0 / 255.0, alpha: 1.0)
    }
    
    class var vtBgWhite: UIColor {
        return UIColor(white: 245.0 / 255.0, alpha: 1.0)
    }
    
    class var vtMainBlue: UIColor {
        return UIColor(red: 66.0 / 255.0, green: 131.0 / 255.0, blue: 228.0 / 255.0, alpha: 1.0)
    }
    
    class var vtTextBlack: UIColor {
        return UIColor(white: 43.0 / 255.0, alpha: 1.0)
    }
    
    class var vtCardShadow: UIColor {
        return UIColor(white: 0.0, alpha: 0.2)
    }
    
    class var vtTitleBg: UIColor {
        return UIColor(white: 0.0, alpha: 0.8)
    }
    
    class var vtLabelG: UIColor {
        return UIColor(red: 55.0 / 255.0, green: 197.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    }
    
    class var vtLabelY: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 185.0 / 255.0, blue: 0.0, alpha: 1.0)
    }
    
    class var vtLabelR: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    
    class var vtKiwiGreen: UIColor {
        return UIColor(red: 145.0 / 255.0, green: 220.0 / 255.0, blue: 58.0 / 255.0, alpha: 1.0)
    }
    
    class var vtHeart: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0, alpha: 1.0)
    }
    
    class var vtBlack: UIColor {
        return UIColor(white: 0.0, alpha: 1.0)
    }
    
    class var vtTextGrey: UIColor {
        return UIColor(white: 120.0 / 255.0, alpha: 1.0)
    }
    
    class var vtSubtitleGrey: UIColor {
        return UIColor(white: 227.0 / 255.0, alpha: 1.0)
    }
    
    class var vtGrdientPink: UIColor {
        return UIColor(red: 229.0 / 255.0, green: 112.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
    }
    
    class var vtWaveViewBlue: UIColor {
        return UIColor(red: 210.0 / 255.0, green: 220.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
    class var vtAIRecordBgBlue: UIColor {
        return UIColor(red: 33.0/255.0, green: 43.0/255.0, blue: 54.0/255.0, alpha: 1.0)
    }
    
    class var vtWatermelonRed: UIColor {
        return UIColor(red: 237.0 / 255.0, green: 79.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    }

    class var vtReviewCellBgGrey: UIColor {
        return UIColor(red: 240.0/255.0, green: 241.0/255.0, blue: 246.0/255.0, alpha: 1.0)
    }

    class var vtUserCountRed: UIColor {
        return UIColor(red: 237.0/255.0, green: 79.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    }

    class var vtBottomLineGrey: UIColor {
        return UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0)
    }
}

// Text styles with Zeplin

extension UIFont {
    
    class func vtDictationNumberFont() -> UIFont {
        return UIFont.systemFont(ofSize: 36, weight: UIFont.Weight.medium)
    }
    
    class func vtXlTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 25.0, weight: UIFont.Weight.medium)
    }
    
    class func vtHeadline20PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.semibold)
    }
    
    class func vtTitle20PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
    }
    
    class func vtSubTitle20PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.regular)
    }
    
    class func vtHeadline17PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)
    }
    
    class func vtTitle17PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  17.0, weight: UIFont.Weight.medium)
    }
    
    class func vtHeadline16PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  16.0, weight: UIFont.Weight.semibold)
    }
    
    class func vtTitle16PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  16.0, weight: UIFont.Weight.medium)
    }
    
    class func vtText16PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  16.0, weight: UIFont.Weight.light)
    }
    
    class func vtTitle15PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  15.0, weight: UIFont.Weight.medium)
    }
    
    class func vtFilter15PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize:  15.0, weight: UIFont.Weight.regular)
    }
    
    class func vtSubTitle17PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.regular)
    }
    
    class func vtVocabularyFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.regular)
    }
    
    class func vtChannelTitleFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
    }

    class func vtPriceFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 25.0, weight: UIFont.Weight.medium)
    }
    
    class func vtBlogTitleFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.semibold)
    }
    
    class func vtChannelTitleEnFont() -> UIFont {
        return UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    }
    
    class func vtTitle14PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    }
    
    class func vtBody14PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.regular)
    }
    
    class func vtFootnote13PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
    }
    
    class func vtDuration13PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
    }
    
    class func vtCaption11PtFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
    }
    
    class func vtDate11PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.regular)
    }

    class func vtFlag11PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 11.0, weight: UIFont.Weight.medium)
    }

    class func vtDictationProgress12PtFont() -> UIFont {
        return UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
    }
    
    class func vtAIRecordScoreFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 33.0, weight: UIFont.Weight.medium)
    }

    class func vtOriginalPriceFont() -> UIFont? {
        return UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
    }
}
