//
//  DashboardController.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import EasyStash

class DashboardController: UIViewController {
    @IBAction func logOutButton(_ sender: UIButton) {
        AuthData.shared.accessToken = ""
        do {
            var options = Options()
            options.folder = "Users"
            let storage = try! Storage(options: options)
            try storage.save(object: AuthData.shared.accessToken, forKey: "accessToken")
        }
        catch {
        }
    }

    @IBAction func newDietButton(_ sender: UIButton) {
        post(method: "POST", endPoint: "generate_diet", postString: "diet_type=standard&goal=maintain", completion: { response, status in
            
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
                                        let desc = dine["description"] as? NSString {
                                        let recipe = UserData.Recipe(name: name as String, description: desc as String)
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
                    showAlert(controller: self, title: "Error", message: message)
                }
            } else {
                showAlert(controller: self, title: "Error", message: "Network error: could not connect")
            }
        })
    }
}
