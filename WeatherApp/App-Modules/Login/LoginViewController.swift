//
//  ViewController.swift
//  WeatherApp
//
//  Created by Chaithra on 2/15/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import UIKit
import GoogleSignIn
import LocalAuthentication

class LoginViewController: UIViewController  {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseGoogleSignIn()
    }
    
    func initialiseGoogleSignIn(){
        signInButton.style = GIDSignInButtonStyle.iconOnly
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        GIDSignIn.sharedInstance().delegate = self
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            if email.isValidEmail() && password.isValidPassword(){
                loginUser(email: email, password: password)
            }
            else {
                displayAlertView("Invalid Email or Password")
            }
        }
    }
    
    @IBAction func socialLoginAction(_ sender: Any) {
        displayAlertView("This Feature Yet to Implement")
    }
    

    func loginUser(email: String, password: String){
        showProgressIndicator(view: self.view)
        let param = "email=eve.holt@reqres.in&password=cityslicka"
        NetworkHandler().postData(params: param, urlString: "https://reqres.in/api/login") { (data, error) in
            hideProgressIndicator(view: self.view)
            if let error = error {
                self.displayAlertView(error.localizedDescription)
            }
            if let data = data as? NSDictionary {
                if let token = data["token"] as? String{
                    self.navigateToWeatherView(userName: self.nameFromEmail(email: email), userId: token)
                }
            }
        }
    }
    
    func nameFromEmail(email: String) -> String {
        let charSet = NSCharacterSet(charactersIn: ".@")
        let v = email.components(separatedBy: charSet as CharacterSet)
        return v.first ?? "Guest"
    }
    
    func navigateToWeatherView(userName: String, userId: String){
        let weather = WeatherInfoRouter.createModule()
        weather.userName = userName
        weather.userId = userId
        DispatchQueue.main.async {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate {
                appdelegate.window?.rootViewController = weather
            }
        }
    }
    
    func displayAlertView(_ message:String){
        let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController :GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        displayAlertView(error.localizedDescription)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        if let userID = user.userID, let fullName = user.profile.name {
            self.navigateToWeatherView(userName: fullName, userId: userID)
        }
    }
}
