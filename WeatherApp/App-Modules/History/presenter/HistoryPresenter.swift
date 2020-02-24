//
//  HistoryPresenter.swift
//  WeatherApp
//
//  Created by Chaithra T V on 20/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation

class HistoryPresenter: HistoryViewToPresenterProtocol {

    var view: HistoryPresenterToViewProtocol?
    var interactor: HistoryPresenterToInteractorProtocol?
    var router: HistoryPresenterToRouterProtocol?

}

extension HistoryPresenter: HistoryInteractorToPresenterProtocol {
    
}

