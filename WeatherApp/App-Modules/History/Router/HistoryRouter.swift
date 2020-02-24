//
//  HistoryRouter.swift
//  WeatherApp
//
//  Created by Chaithra T V on 20/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import UIKit

class HistoryRouter: HistoryPresenterToRouterProtocol {
    static func createModule() -> HistoryViewController {
        let view = mainstoryboard.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        let presenter: HistoryViewToPresenterProtocol & HistoryInteractorToPresenterProtocol = HistoryPresenter()
        let interactor: HistoryPresenterToInteractorProtocol = HistoryInteractor()
        let router:HistoryPresenterToRouterProtocol = HistoryRouter()

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
