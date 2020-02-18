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

class WeatherInfoInteractor:NSObject, PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?
    let locationManager = CLLocationManager()
    
    func fetchCurrentLocation(){
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
        let urlString = "https://fcc-weather-api.glitch.me/api/current?lat=\(lat)&lon=\(long)"
        NetworkHandler().getData(urlString: urlString) { (data, error) in
            //display Error, data
            guard let responseData = data else{
                return
            }
            
            let weatherInfo = try! JSONDecoder().decode(WeatherInfo.self, from: responseData)
            self.presenter?.weatherInfoReceived(weatherInfo: weatherInfo)
        }
    }
    
    
    func fetchImageForIcon(icon: String) {
        NetworkHandler().getData(urlString: icon) { (data, error) in
            print(error ?? "no error")
            if let imageData = data as Data? {
                if let img = UIImage(data: imageData){
                    self.presenter?.imageReceived(image: img)
                }
            }
        }
    }
}




extension WeatherInfoInteractor:CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location:CLLocation = manager.location else { return }
        locationManager.stopUpdatingLocation()
        presenter?.locationFetched(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        getAddressFromLocation(location)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getAddressFromLocation(_ location: CLLocation) {
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
