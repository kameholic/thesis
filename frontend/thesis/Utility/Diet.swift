//
//  Diet.swift
//  thesis
//
//  Created by Mac on 2019. 12. 01..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import EasyStash

func generateDiet(controller: UIViewController, method:String, endPoint: String, postString: String) {
    post(method: method, endPoint: endPoint, postString: postString, completion: { response, status in
        
        if response != nil, status != nil {
            let message = response!["message"] as! NSDictionary
            
            if status == 200 {
                if let diet = message["diet"] as? NSArray {
                    var i = 0
                    UserData.shared.diet.days.removeAll()
                    for case let day as NSDictionary in diet {
                        print("Day \(i)")
                        var dayData = [String:UserData.Recipe]()
                        for dine_type in ["breakfast", "lunch", "dinner"] {
                            if let dine = day[dine_type] as? NSDictionary {
                                print("Dine \(dine_type)")
                                if  let name = dine["name"] as? NSString,
                                    let desc = dine["description"] as? NSString,
                                    let portion = dine["portion"] as? Double {
                                    let recipe = UserData.Recipe(name: name as String, portion: portion as! Double, description: desc as String)
                                    print("Name \(name) Description \(desc))")
                                    dayData[dine_type] = recipe
                                }
                            }
                        }
                        UserData.shared.diet.days.append(dayData)
                        i += 1
                    }
                    
                    var options = Options()
                    options.folder = "Users"
                    let storage = try! Storage(options: options)
                    do {
                        try storage.save(object: UserData.shared.diet, forKey: "diet")
                    } catch {
                    }
                }
            } else {
                showAlert(controller: controller, title: "Error", message: message)
            }
        } else {
            showAlert(controller: controller, title: "Error", message: "Network error: could not connect")
        }
    })
}
