//
//  Extensions.swift
//  VoiceTube_iOS
//
//  Created by TsauPoPo on 2017/3/28.
//  Copyright © 2017年 VoiceTube. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    // Console Logger
    static let transactionPurchased = "IAP Transaction Purchased"
    static let purchasedButUploadFailed = "IAP Purchased But UploadFailed"
    static let refreshRequsetFinished = "IAP Refresh Requset Finished"
    static let productRequsetFinished = "IAP Product Requset Finished"
    static let iapRequsetFinished = "IAP Requset Error"
    static let iapAddPaymentToQueue = "IAP Add Payment To Queue"

}

extension Int {
    func converToDateString(dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }

    public var digitCountForAttributtedString: Int {
        get {
            if self < 1000  {
                return numberOfDigits(in: self)
            } else if self >= 1000 && self < 1000000 {
                return numberOfDigits(in: self) + 1
            } else if self >= 1000000 {
                return numberOfDigits(in: self) + 2
            } else {
                return numberOfDigits(in: self)
            }
        }
    }

    public var usefulDigitCount: Int {
        get {
            var count = 0
            for digitOrder in 0..<self.digitCountForAttributtedString {

                let digit = self % (Int(truncating: pow(10, digitOrder + 1) as NSDecimalNumber))
                    / Int(truncating: pow(10, digitOrder) as NSDecimalNumber)
                if isUseful(digit) { count += 1 }

            }
            return count
        }
    }

    private func numberOfDigits(in number: Int) -> Int {
        if abs(number) < 10 {
            return 1
        } else {
            return 1 + numberOfDigits(in: number/10)
        }
    }

    private func isUseful(_ digit: Int) -> Bool {
        return (digit != 0) && (self % digit == 0)
    }

}

extension URL {
    static func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory
    }

    static func documentFilePath(fileName: String) -> URL {
        return URL.documentsDirectory().appendingPathComponent(fileName)
    }
}

extension UITableViewCell {
    static var reuseId: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell {
    static var reuseId: String {
        return String(describing: self)
    }
}

extension Dictionary {
    func merge(dict: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var mutableCopy = self
        for (key, value) in dict {
            mutableCopy[key] = value
        }
        return mutableCopy
    }

    func toJsonString() -> String? {

        guard JSONSerialization.isValidJSONObject(self) else {
            print (" Dictionary not valid ")
            return nil }

        let data = try? JSONSerialization.data(withJSONObject: self, options: [])

        let jsonString = String(data: data!, encoding: String.Encoding.utf8)

        return jsonString
    }
}

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

extension UIView {
    func drawBorder(color: UIColor, borderWidth: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = borderWidth
    }

    func drawShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float = 0.0) {
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }

    func setShadowWithCornerRadius(corners : CGFloat){
        self.layer.cornerRadius = corners
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: corners)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: CGFloat(1.0), height: CGFloat(3.0))
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = path.cgPath
    }

    func drawBlackTransparentGradient() {
        let gradientlayer = CAGradientLayer()
        gradientlayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientlayer.endPoint = CGPoint(x: 0.5, y: 0)
        let blackColor = UIColor.vtCardShadow
        gradientlayer.colors = [blackColor.withAlphaComponent(0.6).cgColor, blackColor.withAlphaComponent(0.4).cgColor, blackColor.withAlphaComponent(0.0).cgColor]
        gradientlayer.locations = [NSNumber(value: 0), NSNumber(value: 0.3), NSNumber(value: 1)]
        gradientlayer.frame = bounds
        layer.insertSublayer(gradientlayer, at: 0)
    }
    
    func applyGradientStyle(colors: [CGColor],
                            startPoint: CGPoint = CGPoint(x: 0, y: 0),
                            endPoint: CGPoint = CGPoint(x: 1, y: 1),
                            locations: [NSNumber]? = nil) {
        let gradientlayer = CAGradientLayer()
        gradientlayer.colors = colors
        gradientlayer.startPoint = startPoint
        gradientlayer.endPoint = endPoint
        gradientlayer.locations = locations
        gradientlayer.frame = frame
        layer.insertSublayer(gradientlayer, at: 0)
    }

    func applyUnderLineStyle(withBottomPadding padding: CGFloat = 80, lineColor: UIColor = .black) {
        class UnderLineLayer: CALayer {
        }

        if let layers = self.layer.sublayers,
            layers.filter({ layer in layer is UnderLineLayer }).count != 0 {
            layers[0].bounds = CGRect(x: 0.0, y: frame.height - padding, width: frame.width, height: 0.5)
            layers[0].backgroundColor = lineColor.cgColor
        } else {

            let bottomLine = UnderLineLayer()
            bottomLine.frame = CGRect(x: 0.0, y: frame.height - padding, width: frame.width, height: 0.5)
            bottomLine.backgroundColor = lineColor.cgColor
            layer.addSublayer(bottomLine)
        }
    }

    func round(corners: UIRectCorner, radius: CGFloat) {
        _ = _round(corners: corners, radius: radius)
    }

    func round(corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let mask = _round(corners: corners, radius: radius)
        addBorder(mask: mask, borderColor: borderColor, borderWidth: borderWidth)
    }

    func fullyRound(diameter: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = diameter / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor;
    }
}

private extension UIView {

    @discardableResult func _round(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        return mask
    }

    func addBorder(mask: CAShapeLayer, borderColor: UIColor, borderWidth: CGFloat) {
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.lineWidth = borderWidth
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }

}

extension UILabel {

    func setTextWithAttributes(text: String, lineHeight: CGFloat, font: UIFont, textColor: UIColor, alignment: NSTextAlignment, lineBreakMode: NSLineBreakMode = .byWordWrapping) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSMakeRange(0, attributedString.length))
        attributedText = attributedString
    }
    
    func setTextLineHeight(text: String, lineHeight: CGFloat) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
    }
}

extension UITextView {
    
    func setTextWithAttributes(text: String, lineHeight: CGFloat, font: UIFont, textColor: UIColor, alignment: NSTextAlignment, lineBreakMode: NSLineBreakMode = .byWordWrapping) {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSMakeRange(0, attributedString.length))
        attributedText = attributedString
    }
}

extension UIViewController {

    func baseSetup(with NavTitle: String = "") {
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        navigationItem.title = NavTitle
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = []
    }

    /**
     @return Bool true means popped successful, false means the navigation stack don't have controller in controllerType
     */
    func tryPopTo<T>(controllerType _: T.Type) -> Bool where T: UIViewController {
        guard let navController = navigationController else {
            fatalError("controller must in a navigationController")
        }

        var childControllers = navController.viewControllers

        let controllerIndex = childControllers.index(of: self)!
        guard controllerIndex == childControllers.count - 1 else {
            fatalError("the controller must be the top controller in nav stack")
        }

        let i = childControllers.index { $0 is T }
        guard let index = i else {
            return false
        }

        if controllerIndex - index == 1 {
            navController.popViewController(animated: true)
            return true
        }

        for i in (index + 1) ..< controllerIndex {
            childControllers.remove(at: i)
        }
        navController.popViewController(animated: true)
        return true
    }
    
    func leave(animated: Bool) {
        if let index = navigationController?.viewControllers.index(of: self), index > 0 {
            navigationController?.popViewController(animated: animated)
        } else if presentingViewController != nil {
            dismiss(animated: animated)
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController  {
            dismiss(animated: animated)
        } else if tabBarController?.presentingViewController is UITabBarController {
            dismiss(animated: animated)
        } else {
            navigationController?.popViewController(animated: animated)
        }
    }
}

extension UIButton {

    func applyBottomLine(color: UIColor, spacing: CGFloat = 8) {
        titleLabel!.sizeToFit()
        let labelSize = titleLabel!.bounds.size
        UIGraphicsBeginImageContextWithOptions(CGSize(width: labelSize.width, height: 1), false, 0)
        let rectPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: labelSize.width, height: 1))

        color.setFill()
        rectPath.fill()

        let line = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        setImage(line, for: .normal)

        imageEdgeInsets = UIEdgeInsets(top: spacing, left: labelSize.width, bottom: -spacing, right: -labelSize.width)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: -labelSize.width, bottom: 0, right: 0)
    }

    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }

    func swapTextAndImage(spacing: CGFloat = 0) {
        titleLabel!.sizeToFit()

        let buttonImage = image(for: .normal)!

        let offset = spacing / 2

        imageEdgeInsets = UIEdgeInsets(top: 0,
                                       left: titleLabel!.bounds.size.width + offset,
                                       bottom: 0,
                                       right: -(titleLabel!.bounds.size.width + offset))

        titleEdgeInsets =
            UIEdgeInsets(top: 0,
                         left: -(buttonImage.size.width + offset),
                         bottom: 0,
                         right: buttonImage.size.width + offset)
    }

    func setupSavedImageWithSelectedStatus() {
        contentMode = .scaleAspectFill
        setImage(UIImage(named: "favorite_disable")?.withRenderingMode(.alwaysOriginal), for: .normal)
        setImage(UIImage(named: "favorite_enable")?.withRenderingMode(.alwaysOriginal), for: .selected)
    }
}

public let defaultButtonInset = UIEdgeInsets(top: 12, left: 36, bottom: 12, right: 36)

extension UIButton {
    
    public func fillColor(color: UIColor) {
        let imageColor = UIImage.from(color: color)
        setBackgroundImage(imageColor, for: .normal)
    }
    
    public func applyCircleStrokeCorner(color: UIColor, forState state: UIControl.State) {
        let roundedImage = UIImage.circle(fromColor: color, strokeWidth: 0.5, size: bestSize())
        setBackgroundImage(roundedImage, for: state)
    }

    public func applyCircleGradientCorner(forState state: UIControl.State) {
        let size = bestSize()
        let circleImage = UIImage.circle(fromColor: UIColor(patternImage: UIImage.mainGradient(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))), size: size)

        setBackgroundImage(circleImage, for: state)
    }

    public func applyRoundedStrokeCorner(color: UIColor, forState state: UIControl.State) {
        let roundedImage = UIImage.roundedCorner(fromColor: color, strokeWidth: 0.5, size: bestSize())
        setBackgroundImage(roundedImage, for: state)
    }

    public func applyRoundedGradientCorner(forState state: UIControl.State) {
        let size = bestSize()
        let roundedImage = UIImage.roundedCorner(fromColor: UIColor(patternImage: UIImage.mainGradient(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))), size: size)
        setBackgroundImage(roundedImage, for: state)
    }

    public func applyPill(color: UIColor) {
        contentEdgeInsets = defaultButtonInset
        let pill = UIImage.pillImage(fromColor: color, size: bestSize())
        setBackgroundImage(pill, for: .normal)
        setTitleColor(UIColor.white, for: .normal)
    }

    public func applyGradientStroke(withInsets insets: UIEdgeInsets = defaultButtonInset) {
        contentEdgeInsets = insets

        let size = bestSize()

        let mainGradientColor = UIColor(patternImage: UIImage.mainGradient(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height)))

        let roundedStrokeGradientImage =
            UIImage.roundedCorner(fromColor: mainGradientColor,
                                  strokeWidth: 1,
                                  size: size,
                                  radius: size.height / 2)

        setBackgroundImage(roundedStrokeGradientImage, for: .normal)
    }

    public func applyGradientStyle(inset: UIEdgeInsets = defaultButtonInset) {

        contentEdgeInsets = inset

        let size = bestSize()

        let gradientImage = UIImage.mainGradient(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let pill = UIImage.pillImage(fromImage: gradientImage, size: size)
        setBackgroundImage(pill, for: .normal)
        setBackgroundImage(UIImage.pillImage(fromColor: UIColor.vtMainBlue, size: size), for: .highlighted)
        setTitleColor(UIColor.white, for: .normal)
    }

    fileprivate func bestSize() -> CGSize {
        let constraintWidth = constraints.findConstant(of: .width)
        let constraintHeight = constraints.findConstant(of: .height)

        sizeToFit()

        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height

        return CGSize(width: constraintWidth ?? boundsWidth,
                      height: constraintHeight ?? boundsHeight)
    }
}

extension Array where Element: NSLayoutConstraint {
    func findConstant(of attribute: NSLayoutConstraint.Attribute) -> CGFloat? {
        return filter { $0.firstAttribute == attribute }
            .map { $0.constant }
            .first
    }
}

extension UIImage {
    
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

    public class func pillImage(fromColor color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let path = UIBezierPath()
        path.addArc(
            withCenter: CGPoint(x: size.height / 2, y: size.height / 2),
            radius: size.height / 2,
            startAngle: CGFloat(0.5 * Float.pi),
            endAngle: CGFloat(1.5 * Float.pi),
            clockwise: true)
        path.addArc(
            withCenter: CGPoint(x: size.width - size.height / 2, y: size.height / 2),
            radius: size.height / 2,
            startAngle: CGFloat(1.5 * Float.pi),
            endAngle: CGFloat(0.5 * Float.pi),
            clockwise: true)

        color.setFill()
        path.fill()
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage!
    }

    public class func circle(fromColor color: UIColor, strokeWidth: CGFloat? = nil, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let boundStrokeWidth = strokeWidth ?? 0
        let path = UIBezierPath(roundedRect: CGRect(x: boundStrokeWidth / 2, y: boundStrokeWidth / 2, width: size.width - boundStrokeWidth, height: size.height - boundStrokeWidth), cornerRadius: size.width / 2)
        if let strokeWidth = strokeWidth {
            color.setStroke()
            path.lineWidth = strokeWidth
            path.stroke()
        } else {
            color.setFill()
            path.fill()
        }
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }

    public class func roundedCorner(fromColor color: UIColor, strokeWidth: CGFloat? = nil, size: CGSize, radius: CGFloat = 5) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let boundsStrokeWidth = strokeWidth ?? 0
        let path = UIBezierPath(roundedRect: CGRect(x: boundsStrokeWidth / 2, y: boundsStrokeWidth / 2, width: size.width - boundsStrokeWidth, height: size.height - boundsStrokeWidth), cornerRadius: radius)
        if let strokeWidth = strokeWidth {
            color.setStroke()
            path.lineWidth = strokeWidth
            path.stroke()
        } else {
            color.setFill()
            path.fill()
        }
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }

    public class func pillImage(fromImage image: UIImage, size: CGSize) -> UIImage {
        return pillImage(fromColor: UIColor(patternImage: image), size: size)
    }

    public enum GradientDirection {
        case topBottom
        case bottomTop
        case leftRight
        case rightLeft
    }

    public class func gradientImage(frame: CGRect,
                                    startColor: UIColor,
                                    endColor: UIColor,
                                    direction: GradientDirection = .leftRight) -> UIImage {
        let gradientImageLayer = CAGradientLayer()
        gradientImageLayer.frame = frame
        gradientImageLayer.colors = [startColor.cgColor, endColor.cgColor]
        switch direction {
        case .topBottom:
            gradientImageLayer.startPoint = .zero
            gradientImageLayer.endPoint = CGPoint(x: 0, y: 1)
        case .bottomTop:
            gradientImageLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientImageLayer.endPoint = .zero
        case .leftRight:
            gradientImageLayer.startPoint = .zero
            gradientImageLayer.endPoint = CGPoint(x: 1, y: 0)
        case .rightLeft:
            gradientImageLayer.startPoint = CGPoint(x: 1, y: 0)
            gradientImageLayer.endPoint = .zero
        }

        UIGraphicsBeginImageContext(gradientImageLayer.bounds.size)
        gradientImageLayer.render(in: UIGraphicsGetCurrentContext()!)

        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return gradientImage!
    }

    public class func mainGradient(frame: CGRect, direction: GradientDirection = .leftRight) -> UIImage {
        return gradientImage(frame: frame, startColor: UIColor.vtGradientBlue, endColor: UIColor.vtGradientPurple, direction: direction)
    }

    public class func orangeGradient(frame: CGRect) -> UIImage {
        return gradientImage(frame: frame, startColor: UIColor(red: 255 / 255, green: 115 / 255, blue: 115 / 255, alpha: 1), endColor: UIColor(red: 250 / 255, green: 203 / 255, blue: 92 / 255, alpha: 1))
    }

    public class func greenGradient(frame: CGRect) -> UIImage {
        return gradientImage(frame: frame, startColor: UIColor(red: 106 / 255, green: 192 / 255, blue: 55 / 255, alpha: 1), endColor: UIColor(red: 135 / 255, green: 215 / 255, blue: 54 / 255, alpha: 1))
    }

    public class func redGradient(frame: CGRect) -> UIImage {
        return gradientImage(frame: frame, startColor: UIColor(red: 245 / 255, green: 81 / 255, blue: 95 / 255, alpha: 1), endColor: UIColor(red: 229 / 255, green: 112 / 255, blue: 168 / 255, alpha: 1))
    }

    public class func placeHolder() -> UIImage? {
        return UIImage(named: "img_placeholder")
    }
}

extension UIView {
    func animate(withDuration duration: TimeInterval, _ animationBlock: @escaping () -> Void) -> Single<Bool> {
        return Single.create { observer -> Disposable in
            UIView.animate(withDuration: duration, animations: {
                animationBlock()
            }) { finished in
                observer(.success(finished))
            }
            return Disposables.create {
                self.layer.removeAllAnimations()
            }
        }
    }

    func positionIn(view: UIView) -> CGRect {
        if let superview = superview {
            return superview.convert(frame, to: view)
        }
        return frame
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given `object`:
    @discardableResult
    mutating func remove(object: Element) -> Bool {
        if let index = index(of: object) {
            remove(at: index)
            return true
        } else {
            return false
        }
    }
}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension NSMutableAttributedString {
    func addLinkStyle(_ link: String, toRange range: Range<String.Index>) {
        let nsRange = NSMakeRange(
            string.distance(from: string.startIndex, to: range.lowerBound),
            string.distance(from: string.startIndex, to: range.upperBound) - string.distance(from: string.startIndex, to: range.lowerBound)
        )

        addAttributes(
            [
                NSAttributedString.Key.link: link,
                NSAttributedString.Key.foregroundColor: UIColor.blue,
            ]
            , range: nsRange)
    }
}

extension UIViewController {

    /*
     use this method in viewWillDisappear to determine whether the controller is dismissing or popping
     */
    func isDismissingOrPoppingViewController() -> Bool {
        if isBeingDismissed || isMovingFromParent {
            return true
        }
        let isBeingPop = navigationController != nil && !navigationController!.viewControllers.contains(self)
        if isBeingPop {
            return true
        }
        let beingDismissUnderNavigation = navigationController?.isBeingDismissed ?? false
        if beingDismissUnderNavigation {
            return true
        }
        return false
    }
}

extension Date {
    func toRelativeTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: self)
    }

    func toGMTString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return  formatter.string(from: self).replacingOccurrences(of: "GMT", with: "")
    }
}

extension Optional where Wrapped == String {
    var isEmptyString: Bool {
        return self?.isEmpty ?? false
    }
}

enum PanDirection: Int {
    case up, down, left, right
    public var isVertical: Bool { return [.up, .down].contains(self) }
    public var isHorizontal: Bool { return !isVertical }
}

extension UIPanGestureRecognizer {
    
    var direction: PanDirection? {
        let velocity = self.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        switch (isVertical, velocity.x, velocity.y) {
        case (true, _, let y) where y < 0: return .up
        case (true, _, let y) where y > 0: return .down
        case (false, let x, _) where x > 0: return .right
        case (false, let x, _) where x < 0: return .left
        default: return nil
        }
    }
}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)

        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:  locationOfTouchInLabel.y - textContainerOffset.y)

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}

extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }
        
        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
