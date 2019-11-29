//
//  Alert.swift
//  thesis
//
//  Created by Mac on 2019. 11. 25..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit

func showAlert(controller: UIViewController, title:String, message: NSDictionary) {
    DispatchQueue.main.async {
        var msg = ""
        for (key, val) in message {
            msg.append("\(key): \(val)\n")
        }
        let alertController = UIAlertController(title: title, message:
            msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        controller.present(alertController, animated: true, completion: nil)
    }
}

func showAlert(controller: UIViewController, title:String, message: NSString) {
    DispatchQueue.main.async {
        let alertController = UIAlertController(title: title, message:
            String(message), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        controller.present(alertController, animated: true, completion: nil)
    }
}
