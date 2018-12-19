//
//  Utilities.swift
//  VoiceTube_iOS
//
//  Created by TsauPoPo on 2017/4/20.
//  Copyright © 2017年 VoiceTube. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct Utilities {

    static let userDefault = UserDefaults.standard

    static func getAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? "Unknown"
        return "\(appVersion).\(appBuild)"
    }

    static func serializedJSON(_ object: Any) -> String? {
        do {
            // Serialize to JSON string
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted)
            // Succeeded
            return String(data: jsonData, encoding: .utf8)

        } catch let jsonError {
            // JSON serialization failed
            print("Utilities serializedJSONError: \(jsonError)")
            return nil
        }
    }

    static func removeFile(fromUrl url: URL) -> Single<Void> {
        return Single
            .just(url)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .subscribeOn(MainScheduler.instance)
            .map({ (url) -> Void in
                do {
                    let fileManager = FileManager.default
                    try fileManager.removeItem(at: url)
                } catch {
                    print("delete file error")
                    throw NSError() as Error
                }
            })
    }

    static func showAlert(_ cancelAction: UIAlertAction, confirmAction: UIAlertAction, title: String, message: String, viewcontroller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        viewcontroller.present(alertController, animated: true, completion: nil)
    }

    static func showAlert(_ confirmAction: UIAlertAction, title: String, message: String, viewcontroller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "alert.Cancel".localized, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        viewcontroller.present(alertController, animated: true, completion: nil)
    }

    static func showAlert(_ title: String = "alert.Title".localized, message: String, viewcontroller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "alert.OK".localized, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        viewcontroller.present(alertController, animated: true, completion: nil)
    }

    static func showAlertOnTopVC(_ message: String) {

        let topVC = UIApplication.topViewController() ?? UIApplication.shared.keyWindow?.rootViewController
        topVC?.view.endEditing(true)
        let alertController = UIAlertController(title: "alert.Title".localized, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "alert.OK".localized, style: .default, handler: nil)
        alertController.addAction(cancelAction)
        topVC?.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertOnTopVC(_ cancelAction: UIAlertAction, confirmAction: UIAlertAction, title: String, message: String) {
        let topVC = UIApplication.topViewController() ?? UIApplication.shared.keyWindow?.rootViewController
        topVC?.view.endEditing(true)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        topVC?.present(alertController, animated: true, completion: nil)
    }

    static func showAlertOnRootVC(_ message: String, confirmAction: UIAlertAction, cancelAction: UIAlertAction? = nil) {
        let alertController = UIAlertController(title: "alert.Title".localized, message: message, preferredStyle: .alert)
        if let _ = cancelAction {
            alertController.addAction(cancelAction!)
        }
        alertController.addAction(confirmAction)
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        topVC?.view.endEditing(true)
        topVC?.present(alertController, animated: true, completion: nil)
    }
}
