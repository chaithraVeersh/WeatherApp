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
                //  navigateToWeatherView()
                loginUser(email: email, password: password)
            }
            else {
                displayAlertView("Invalid Email or Password")
            }
        }
    }
    
    func loginUser(email: String, password: String){
        let param = "email=eve.holt@reqres.in&password=cityslicka"
        NetworkHandler().postData(params: param, urlString: "https://reqres.in/api/login") { (data, error) in
            if let error = error {
                self.displayAlertView(error.localizedDescription)
            }
            if let data = data as? NSDictionary {
                if let token = data["token"] as? String{
                    self.saveUserInDefaults(userId: token, fullName: self.nameFromEmail(email: email))
                    self.navigateToWeatherView()
                }
            }
        }
    }
    
    func nameFromEmail(email: String) -> String {
        let charSet = NSCharacterSet(charactersIn: ".@")
        let v = email.components(separatedBy: charSet as CharacterSet)
        return v.first ?? "Guest"
    }
    
    func navigateToWeatherView(){
        // ...
        let weather = WeatherInfoRouter.createModule()
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
        // Perform any operations when the user disconnects from app here.
        // ...
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
            saveUserInDefaults(userId: userID, fullName: fullName)
        }
        navigateToWeatherView()
    }
    func saveUserInDefaults(userId:String, fullName:String){
        UserDefaults.standard.set(userId, forKey: "userID")
        UserDefaults.standard.set(fullName, forKey: "fullName")
    }
}
