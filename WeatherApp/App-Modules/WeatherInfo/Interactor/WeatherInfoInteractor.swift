//
//  WeatherInfoInteractor.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import GoogleSignIn
import RealmSwift

class WeatherInfoInteractor:NSObject, PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?
    let locationManager = CLLocationManager()
    var realm: Realm!

    func fetchCurrentLocation(){
        //core location initialization
        DispatchQueue.main.async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.distanceFilter = kCLDistanceFilterNone
                self.locationManager.stopMonitoringSignificantLocationChanges()
                
                if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                    self.locationManager.requestWhenInUseAuthorization()
                }else{
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    func fetchWeatherInfo(lat: Double, long: Double) {
        //weather API call
        let urlString = "https://fcc-weather-api.glitch.me/api/current?lat=\(lat)&lon=\(long)"
        NetworkHandler().getData(urlString: urlString) { (data, error) in
            guard let responseData = data else{
                return
            }
            
            let weatherInfo = try! JSONDecoder().decode(WeatherInfo.self, from: responseData)
            self.presenter?.weatherInfoReceived(weatherInfo: weatherInfo)
        }
    }
    
    
    func fetchImageForIcon(icon: String) {
        //weather image fetch
        NetworkHandler().getData(urlString: icon) { (data, error) in
            if let imageData = data as Data? {
                if let img = UIImage(data: imageData){
                    self.presenter?.imageReceived(image: img)
                }
            }
        }
    }
    
    func logOut() {
        GIDSignIn.sharedInstance()?.signOut()
        removeUserFromDefaults()
    }
    
    func removeUserFromDefaults(){
        UserDefaults.standard.removeObject(forKey: kUserID)
        UserDefaults.standard.removeObject(forKey: kUserName)
    }
    
    func saveUserInDefaults(userId:String, username:String){
        UserDefaults.standard.set(userId, forKey: kUserID)
        UserDefaults.standard.set(username, forKey: kUserName)
    }
    
    func saveLocation(_ location: String, lat: Double, long: Double) {
        if realm == nil {
            realm = try! Realm()
        }
        
        let history = History()
        history.placeName = location
        history.latitude = lat
        history.longitude = long
        
        try! self.realm.write({
            self.realm.add(history)
        })
    }
    
}


extension WeatherInfoInteractor:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted, .denied:
            // restricted by e.g. parental controls. User can't enable Location Services
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //current location
        guard let location:CLLocation = manager.location else { return }
        locationManager.stopUpdatingLocation()
        presenter?.locationFetched(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        getAddressFromLocation(location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getAddressFromLocation(_ location: CLLocation) {
        //reverse geocoding
        let ceo: CLGeocoder = CLGeocoder()
        ceo.reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    var addressString : String = ""
                    guard let pm = placemarks?.first, let sublocality = pm.subLocality, let locality = pm.locality else {
                        return
                    }
                    addressString = sublocality + ", " + locality
                    self.presenter?.placeFetched(string: addressString)
                }
        })
        
    }
}
