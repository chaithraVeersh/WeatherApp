//
//  weatherInfoRouter.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import UIKit

class WeatherInfoRouter: PresenterToRouterProtocol {
    static func createModule() -> WeatherInfoViewController {
        let view = mainstoryboard.instantiateViewController(withIdentifier: "WeatherInfoViewController") as! WeatherInfoViewController
        let presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = WeatherInfoPresenter()
        let interactor: PresenterToInteractorProtocol = WeatherInfoInteractor()
        let router:PresenterToRouterProtocol = WeatherInfoRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter

        return view
    }

    static var mainstoryboard: UIStoryboard{
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
}
