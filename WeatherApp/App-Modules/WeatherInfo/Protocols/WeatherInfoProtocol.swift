//
//  WeatherInfoProtocol.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol ViewToPresenterProtocol: class{
    var view: PresenterToViewProtocol? {get set}
    var interactor: PresenterToInteractorProtocol? {get set}
    var router: PresenterToRouterProtocol? {get set}
    
    func fetchCurrentLocation()
    func fetchWeatherInfo(latitude:Double, longitude: Double)
    func fetchImageForUrl(_ urlString: String)
}

protocol PresenterToViewProtocol: class{
    func showPlaceName(place:String)
    func fetchLocationForCoOrds(latitude: Double, longitude: Double)
    func showWeatherInfo(weather: WeatherInfo)
    func displayImage(image: UIImage)
}

protocol PresenterToRouterProtocol: class {
    static func createModule()-> WeatherInfoViewController
}

protocol PresenterToInteractorProtocol: class {
    var presenter:InteractorToPresenterProtocol? {get set}
    func fetchCurrentLocation()
    func fetchWeatherInfo(lat:Double, long: Double)
    func fetchImageForIcon(icon: String)
}

protocol InteractorToPresenterProtocol: class {
     func locationFetched(latitude:Double, longitude: Double)
     func placeFetched(string: String)
    func weatherInfoReceived(weatherInfo: WeatherInfo)
    func imageReceived(image: UIImage)
}

protocol LocationToInteractorProtocol: class {
    func didfetchLocation(location:CLLocationCoordinate2D)
    func didFailToFetchLocation(error: Error)
}
