//
//  SelectionViewController.swift
//  thesis
//
//  Created by Mac on 2019. 11. 04..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import EasyStash

class SelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var lifeStyleTextField: UITextField!

    @IBOutlet weak var allergiesTableView: UITableView!

    let picker1 = UIPickerView()
    let picker2 = UIPickerView()
    
    var genders = ["Male", "Female"]
    var lifeStyle = ["Sitting", "Normal", "Active"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker1.dataSource = self
        picker1.delegate = self
        
        picker2.dataSource = self
        picker2.delegate = self
        
        genderTextField.inputView = picker1
        lifeStyleTextField.inputView = picker2
        
        ageTextField.text = String(UserData.shared.age)
        weightTextField.text = String(UserData.shared.weight)
        genderTextField.text = UserData.shared.gender
        lifeStyleTextField.text = UserData.shared.lifestyle

        allergiesTableView.dataSource = self
        allergiesTableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserData.shared.allergies[indexPath.row].checked = !UserData.shared.allergies[indexPath.row].checked
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.shared.allergies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        if UserData.shared.allergies[indexPath.row].checked {
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = UserData.shared.allergies[indexPath.row].name
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == picker1 {
            return genders.count
        } else {
            return lifeStyle.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView == picker1 {
            return genders[row]
        } else if pickerView == picker2{
            return lifeStyle[row]
        }
        else {
            print("No pickerview selected.")
        }
        return ("Pickeview not selected")
    }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerView == picker1 {
                genderTextField.text = genders[row]
                self.view.endEditing(false)
            } else if pickerView == picker2 {
                lifeStyleTextField.text = lifeStyle[row]
                self.view.endEditing(false)
            }
            else {
                print("Love love love I want your love")
            }
        }
    @IBAction func saveButton(_ sender: UIButton) {
        if  let gender = genderTextField.text,
            let lifestyle = lifeStyleTextField.text,
            let ageText = ageTextField.text, let age = Int(ageText),
            let weightText = weightTextField.text, let weight = Double(weightText)
        {
            var allergies: [Int] = []
            for (allergy) in UserData.shared.allergies {
                if allergy.checked {
                    allergies.append(allergy.id)
                }
            }
            let params: [String:Any] = [
                "gender": gender.lowercased(),
                "lifestyle": lifestyle.lowercased(),
                "age": age,
                "weight": weight,
                "allergies": allergies
            ]
            
            post(method: "POST", endPoint: "user_infos", postData: params, completion: { response, status in
                if response != nil, status != nil {
                    if status != 200 {
                        if let message = response!["message"] as? NSDictionary? {
                            showAlert(controller: self, title: "Error", message: message!)
                        }
                        else if let message = response!["message"] as? NSString? {
                            showAlert(controller: self, title: "Error", message: message!)
                        }
                    }
                    else {
                        print("Info saved")
                        do {
                            var options = Options()
                            options.folder = "Users"
                            let storage = try! Storage(options: options)
                            
                            try storage.save(object: UserData.shared.age, forKey: "age")
                            try storage.save(object: UserData.shared.gender, forKey: "gender")
                            try storage.save(object: UserData.shared.lifestyle, forKey: "lifestyle")
                            try storage.save(object: UserData.shared.weight, forKey: "weight")
                            try storage.save(object: UserData.shared.allergies, forKey: "allergies")
                            
                            print("Saved to local database")
                        }
                        catch {
                        }
                    }
                } else {
                    showAlert(controller: self, title: "Error", message: "Network error: could not connect")
                }
            })
        }
    }
}

