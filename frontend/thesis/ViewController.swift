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
    @IBOutlet weak var buttonClick: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bigtextview: UITextView!
    
    @IBAction func clickme(_ sender: Any) {
        // create post request
        let url = URL(string: "http://127.0.0.1:5000/schools")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            let convertedString = String(data: data, encoding: String.Encoding.utf8)
            self.bigtextview.text = convertedString
        }
        
        task.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pullAllergies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthData.shared.accessToken == "" {
            self.loadAccessToken()
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
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
    
    @IBAction func logInButton(_ sender: UIButton) {
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
                        self.pullData()
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueLogin", sender: self)
                        }
                    }
                    else {
                        showAlert(controller: self, title:"Error", message: message)
                    }
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
                        for (id, name) in allergies {
                            if  let _id = id as? String,
                                let _name = name as? String {
                                UserData.shared.allergies.append(UserData.Allergy(id: Int(_id)!, name: _name))
                            } else {
                                print("Bad allergy \(id):\(name)")
                            }
                        }
                    }
                }
                else {
                    showAlert(controller: self, title: "Error", message: message)
                }
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
                        let weight = message["weight"] as? Double {

                        UserData.shared.age = age
                        UserData.shared.gender = gender.capitalized
                        UserData.shared.lifestyle = lifestyle.capitalized
                        UserData.shared.weight = weight
                    }
                }
                else {
                    showAlert(controller: self, title: "Error", message: message)
                }
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
                    let allergies = try storage.load(forKey: "allergies", as: [UserData.Allergy].self)
                    UserData.shared.age = age
                    UserData.shared.gender = gender
                    UserData.shared.lifestyle = lifestyle
                    UserData.shared.weight = weight
                    UserData.shared.allergies = allergies
                    
                    print("Loaded from local database")
                }
                catch {
                }
                
                print(AuthData.shared.accessToken)
                if AuthData.shared.accessTokenIsValid() {
                    self.pullData()
                    self.performSegue(withIdentifier: "segueLogin", sender: self)
                }
            } catch {
            }
        }
    }

}
    
    

