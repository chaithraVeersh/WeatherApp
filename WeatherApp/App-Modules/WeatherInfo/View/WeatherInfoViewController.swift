//
//  WeatherInfoViewController.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import UIKit
import GooglePlaces
import LocalAuthentication

class WeatherInfoViewController: UIViewController {
    var presenter:ViewToPresenterProtocol?
    let localAuthenticationContext = LAContext()
    
    @IBOutlet weak var displayTextLabel: UILabel!
    @IBOutlet weak var placesTextField: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var minimumTempLabel: UILabel!
    @IBOutlet weak var maximumTempLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        //touch ID Authentication
        authenticationWithTouchID()
        
        //display LoggedIn user name
        if let name =  UserDefaults.standard.value(forKey: "fullName") as? String {
            displayTextLabel.text = "Hey \(name)!"
        }
    }
    
    func setupUI() {
        //add edit button to textField
        let editImgeView = UIImageView(frame: CGRect(x: placesTextField.frame.size.width - 40 , y: 5, width: 22, height: 22))
        editImgeView.image = UIImage(named: "edit");
        placesTextField.rightView = editImgeView
        placesTextField.rightViewMode = .always
    }
    
    @IBAction func textFieldTapped(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
    
}

extension WeatherInfoViewController:PresenterToViewProtocol {
    
    func showPlaceName(place: String) {
        DispatchQueue.main.async {
            self.placesTextField.text = place
        }
    }
    
    func showCurrentLocation(latitude: Double, longitude: Double) {
        showProgressIndicator(view: self.view)
        presenter?.fetchWeatherInfo(latitude: latitude, longitude: longitude)
    }
    
    func showWeatherInfo(weather: WeatherInfo) {
        hideProgressIndicator(view: self.view)
        
        DispatchQueue.main.async {
            self.descriptionLabel.text = weather.data.first?.description
            self.temperatureLabel.text = "\(weather.temp)°"
            
            self.minimumTempLabel.text = "\(weather.tempMin)°"
            self.maximumTempLabel.text = "\(weather.tempMax)°"
            
            self.humidityLabel.text = "\(weather.humidity)"
            self.pressureLabel.text = "\(weather.pressure)"
            
            self.sunriseLabel.text = weather.sunrise.getTimeFromInterval()
            self.sunsetLabel.text =  weather.sunset.getTimeFromInterval()
            
            if let icon = weather.data.first?.icon {
                self.presenter?.fetchImageForUrl(icon)
            }
        }
    }
    
    func showImageForWeather(image: UIImage) {
        DispatchQueue.main.async {
            self.descImageView.image = image
        }
    }
}

extension WeatherInfoViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Get the place name from 'GMSAutocompleteViewController'
        // Then display the name in textField
        presenter?.fetchWeatherInfo(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        placesTextField.text = place.name
        // Dismiss the GMSAutocompleteViewController when something is selected
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Handle the error
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Dismiss when the user canceled the action
        dismiss(animated: true, completion: nil)
    }
}


extension WeatherInfoViewController {
    
    func authenticationWithTouchID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    self.presenter?.fetchCurrentLocation()
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    self.displayTouchIDAlertView(error.localizedDescription)
                }
            }
        } else {
            guard let error = authError else {
                return
            }
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            displayTouchIDAlertView("TouchID/FaceID is lockout or not enrolled in device")
        }
    }
    
    func displayTouchIDAlertView(_ message:String){
        let alert = UIAlertController.init(title: "Authentication Failed", message: "Unlock with Touch ID to use WeatherApp", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Use Touch Id", style: .cancel) { (action:UIAlertAction!) in
            self.authenticationWithTouchID()
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
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
