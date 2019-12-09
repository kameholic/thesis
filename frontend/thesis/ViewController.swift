    //
//  ViewController.swift
//  thesis
//
//  Created by Mac on 2019. 09. 14..
//  Copyright © 2019. Mac. All rights reserved.
//

import UIKit
import EasyStash

class ViewController: UIViewController {
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthData.shared.accessToken == "" {
            self.pullAllergies()
            self.loadAccessToken()
        }
    }
    
    @IBAction func logInButton(_ sender: UIButton) {
        print("Login pressed")
        if  let email = emailTextField.text,
            let password = passwordTextField.text {

            post(method: "POST", endPoint: "login", postString: "email=\(email)&password=\(password)", completion: { response, status in
                
                if response != nil, status != nil {
                    let message = response!["message"] as! NSDictionary
                    if status == 200 {
                        AuthData.shared.accessToken = message["access_token"] as! String
                        
                        do {
                            var options = Options()
                            options.folder = "Users"
                            let storage = try! Storage(options: options)
                            try storage.save(object: AuthData.shared.accessToken, forKey: "accessToken")
                        }
                        catch let error {
                            print(error.localizedDescription)
                        }
                        
                        print(AuthData.shared.accessToken)
                        self.pullAllergies()
                        self.pullData()
                        generateDiet(controller: self, method: "GET", endPoint: "generate_diet", postData: [String:Any]())
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueLogin", sender: self)
                        }
                    }
                    else {
                        showAlert(controller: self, title:"Error", message: message)
                    }
                } else {
                    showAlert(controller: self, title: "Error", message: "Network error: could not connect")
                }
            })
        }
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let registrationVC = RegistrationViewController()
        
        self.present(registrationVC, animated: true, completion: nil)
        
    }
    public static func getTopViewController() -> UIViewController?{
        if var topController = UIApplication.shared.keyWindow?.rootViewController
        {
            while (topController.presentedViewController != nil)
            {
                topController = topController.presentedViewController!
            }
            return topController
        }
        return nil
    }
    
    private func pullAllergies() {
        print("pullAllergies")
        post(method: "GET", endPoint: "allergies", postString: "", completion: { response, status in
            if response != nil, status != nil {
                let message = response!["message"] as! NSDictionary
                if status == 200 {
                    if let allergies = message["allergies"] as? NSDictionary {
                        UserData.shared.allergies.removeAll()
                        for (id, name) in allergies {
                            if  let _id = id as? String,
                                let _name = name as? String {
                                UserData.shared.allergies.append(UserData.Allergy(id: Int(_id)!, name: _name))
                            } else {
                                print("Bad allergy \(id):\(name)")
                            }
                        }
                        print("Allergies pulled")
                    }
                }
                else {
                    showAlert(controller: self, title: "Error", message: message)
                }
            } else {
                showAlert(controller: self, title: "Error", message: "Network error: could not connect")
            }
        })
    }
    
    private func pullData() {
        post(method: "GET", endPoint: "user_infos", postString: "", completion: { response, status in
            if response != nil, status != nil {
                let message = response!["message"] as! NSDictionary
                if status == 200 {
                    if  let age = message["age"] as? Int,
                        let gender = message["gender"] as? String,
                        let lifestyle = message["lifestyle"] as? String,
                        let weight = message["weight"] as? Double,
                        let height = message["height"] as? Double,
                        let allergies = message["allergies"] as? [Int] {

                        UserData.shared.age = age
                        UserData.shared.gender = gender.capitalized
                        UserData.shared.lifestyle = lifestyle.capitalized
                        UserData.shared.weight = weight
                        UserData.shared.height = height
                        
                        for (id) in allergies {
                            for index in 0..<UserData.shared.allergies.count {
                                if UserData.shared.allergies[index].id == id {
                                    UserData.shared.allergies[index].checked = true
                                }
                            }
                        }
                    }
                }
                else {
                    showAlert(controller: self, title: "Error", message: message)
                }
            } else {
                showAlert(controller: self, title: "Error", message: "Network error: could not connect")
            }
        })
    }
    
    private func loadAccessToken() {
        DispatchQueue.main.async {
            do {
                var options = Options()
                options.folder = "Users"
                let storage = try! Storage(options: options)
                let accessToken = try storage.load(forKey: "accessToken", as: String.self)
                AuthData.shared.accessToken = accessToken

                do {
                    let gender = try storage.load(forKey: "gender", as: String.self)
                    let age = try storage.load(forKey: "age", as: Int.self)
                    let lifestyle = try storage.load(forKey: "lifestyle", as: String.self)
                    let weight = try storage.load(forKey: "weight", as: Double.self)
                    let height = try storage.load(forKey: "height", as: Double.self)
                    let allergies = try storage.load(forKey: "allergies", as: [UserData.Allergy].self)
                    let diet = try storage.load(forKey: "diet", as: UserData.Diet.self)
                    UserData.shared.age = age
                    UserData.shared.gender = gender
                    UserData.shared.lifestyle = lifestyle
                    UserData.shared.weight = weight
                    UserData.shared.height = height
                    UserData.shared.allergies = allergies
                    UserData.shared.diet = diet
                    
                    print("Loaded from local database")
                }
                catch {
                }
                
                print(AuthData.shared.accessToken)
                if AuthData.shared.accessTokenIsValid() {
                    self.pullData()
                    generateDiet(controller: self, method: "GET", endPoint: "generate_diet", postData: [String:Any]())
                    self.performSegue(withIdentifier: "segueLogin", sender: self)
                }
            } catch {
            }
        }
    }

}
    
    

