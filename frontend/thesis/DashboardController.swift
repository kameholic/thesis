//
//  DashboardController.swift
//  thesis
//
//  Created by Mac on 2019. 11. 30..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import EasyStash

class DashboardController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let picker1 = UIPickerView()
    let picker2 = UIPickerView()
    var dietTypes = ["Complex", "Simple"]
    var goals = ["Lose", "Maintain", "Gain"]

    @IBOutlet weak var dietTypeTextfield: UITextField!
    @IBOutlet weak var goalTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker1.dataSource = self
        picker1.delegate = self

        picker2.dataSource = self
        picker2.delegate = self
        
        dietTypeTextfield.inputView = picker1
        goalTextfield.inputView = picker2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == picker1 {
            return dietTypes.count
        } else {
            return goals.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == picker1 {
            return dietTypes[row]
        } else if pickerView == picker2 {
            return goals[row]
        }
        return ("Pickeview not selected")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == picker1 {
            dietTypeTextfield.text = dietTypes[row]
            self.view.endEditing(false)
        } else if pickerView == picker2 {
            goalTextfield.text = goals[row]
            self.view.endEditing(false)
        }
    }

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
        if  let dietType = dietTypeTextfield.text,
            let goal = goalTextfield.text?.lowercased()
        {
            let is_complex = dietType == "Complex" ? true : false
            print("is_complex: \(is_complex)")
            let postData: [String:Any] = ["diet_type": "standard", "goal": goal, "is_complex": is_complex]
            generateDiet(controller: self, method: "POST", endPoint: "generate_diet", postData: postData)
        }
    }
}
