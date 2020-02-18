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
    
    let localAuthenticationContext = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialiseGoogleSignIn()
        authenticationWithTouchID()
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


extension LoginViewController {
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    //TODO: User authenticated successfully, take appropriate action
                    
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}
