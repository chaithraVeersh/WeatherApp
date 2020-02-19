//
//  WeatherInfoPresenter.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import UIKit

class WeatherInfoPresenter: ViewToPresenterProtocol {
    var interactor: PresenterToInteractorProtocol?
    var router: PresenterToRouterProtocol?
    var view:PresenterToViewProtocol?
    
    func fetchCurrentLocation(){
        interactor?.fetchCurrentLocation()
    }

    func fetchWeatherInfo(latitude: Double, longitude: Double) {
        interactor?.fetchWeatherInfo(lat: latitude, long: longitude)

    }
    
    func fetchImageForUrl(_ urlString: String) {
        interactor?.fetchImageForIcon(icon: urlString)
    }
    
}

extension WeatherInfoPresenter : InteractorToPresenterProtocol {
    func imageReceived(image: UIImage) {
        view?.showImageForWeather(image: image)
    }
    
    func weatherInfoReceived(weatherInfo: WeatherInfo) {
        view?.showWeatherInfo(weather: weatherInfo)
    }
    
    func locationFetched(latitude: Double, longitude: Double) {
        view?.showCurrentLocation(latitude: latitude, longitude: longitude)
    }
    
    func placeFetched(string: String) {
        view?.showPlaceName(place: string)
    }
    
    
}
