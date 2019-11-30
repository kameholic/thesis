import UIKit

class RegistrationViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if passwordTextField.text != reenterPasswordTextField.text {
            showAlert(controller: self, title: "Error", message: "Passwords do not match")
        }
        else {
            let postString = "email=\(emailTextField.text ?? "" )&password=\(passwordTextField.text ?? "")"
            post(method: "POST", endPoint: "register", postString: postString, completion: { response, status  in
                if response != nil, status != nil {
                    if status != 200 {
                        let message = response!["message"] as! NSDictionary
                        showAlert(controller: self, title: "Error", message: message)
                    }
                    else {
                        print("Successfully registered")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueSignUp", sender: self)
                        }
                    }
                } else {
                    showAlert(controller: self, title: "Error", message: "Network error: could not connect")
                }
            })
        }
    }
}
