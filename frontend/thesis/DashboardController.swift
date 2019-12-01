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
        generateDiet(controller: self, method: "POST", endPoint: "generate_diet", postString: "diet_type=standard&goal=maintain")
    }
}
