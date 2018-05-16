//
//  LoginViewController.swift
//  on-the-map
//
//  Created by Pedro De Morais Chiossi on 08/05/18.
//  Copyright © 2018 Pedro Chiossi. All rights reserved.
//

import UIKit
import Foundation
import FBSDKLoginKit
import SafariServices
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, SFSafariViewControllerDelegate {
    
    var session = URLSession.shared
    
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var signupButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
         if FBSDKAccessToken.currentAccessTokenIsActive() {
            facebookAutoLogin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        fbLoginButton.isHidden = FBSDKAccessToken.currentAccessTokenIsActive()
        clearTextFields()
        wheel.stopAnimating()
    
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    
    //  facebook token is cached by default
    func facebookAutoLogin() {
       
        let token = FBSDKAccessToken.current().tokenString
        UdacityClient.sharedInstance().facebookLogin(accessToken: token!) { (success, error) in
            if success{
                DispatchQueue.main.async{
                    self.continueLogin()
                }} else {
                self.showAlert(error?.localizedDescription ?? "Unknown error ocurred")
            }
        }
    }
    
    
    // Facebook Login Button Delegate Methods
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        else if result.isCancelled{
            print("User canceled login")
        }
        else if result.token != nil{
            if let fbToken = result.token.tokenString{
                UdacityClient.sharedInstance().facebookLogin(accessToken: fbToken) { (success, error) in
                    if success{
                        DispatchQueue.main.async {
                        self.continueLogin()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showAlert(error?.localizedDescription ?? "Unknown error ocurred")
                        }
                    }
                }
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Loged out")
    }
    
    
    func continueLogin() {
            let mapNC = self.storyboard?.instantiateViewController(withIdentifier: "studentsNC") as! UINavigationController
            self.present(mapNC, animated: true, completion: nil)
        }
        
    
    
    @IBAction func udacitySignUp(_ sender: Any) {
        
        clearTextFields()
        let urlToLoad = URL(string: Udacity.Constants.SignUpURL)!
        let safariVC =  SFSafariViewController(url: urlToLoad)
        present(safariVC, animated: true,completion: nil)
        safariVC.delegate = self
    }
    
  
    
    @IBAction func udacityLogIn(_ sender: Any) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty{
            showAlert("Email or Password are empty!")
        } else {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            wheel.startAnimating()
            UdacityClient.sharedInstance().udacityLogin(email: email, password: password) { (success, error) in
                
                if success {
                    DispatchQueue.main.async {
                        self.continueLogin()
                    }
                } else {
                    DispatchQueue.main.async(execute: {
                        self.wheel.stopAnimating()
                        self.showAlert(error?.localizedDescription)
                    })
                }
            }
        }
    }
    
    

    func configureView() {
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        udacityLoginButton.layer.cornerRadius = 4.0
        emailTextField.layer.cornerRadius = 4.0
        passwordTextField.layer.cornerRadius = 4.0
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email"]
    }
    
    
    
        func showAlert( _ message: String?) {
            let alert = UIAlertController(title: "Login Failed!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    // Keyboard Notification Methods


    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self)
    }


    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }


    @objc func keyboardWillShow(_ notification:Notification) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            if passwordTextField.isFirstResponder{
                view.frame.origin.y -= 0.5 * getKeyboardHeight(notification)
            }
        }
    }
    

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func clearTextFields() {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    
}





