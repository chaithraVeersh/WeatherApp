//
//  HistoryProtocol.swift
//  WeatherApp
//
//  Created by Chaithra T V on 20/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation

protocol HistoryViewToPresenterProtocol: class{
    var view: HistoryPresenterToViewProtocol? {get set}
    var interactor: HistoryPresenterToInteractorProtocol? {get set}
    var router: HistoryPresenterToRouterProtocol? {get set}
    
}

protocol HistoryPresenterToViewProtocol: class{
    
}

protocol HistoryPresenterToRouterProtocol: class {
    static func createModule()-> HistoryViewController
}

protocol HistoryPresenterToInteractorProtocol: class {
    var presenter:HistoryInteractorToPresenterProtocol? {get set}
}

protocol HistoryInteractorToPresenterProtocol: class {
    
}

protocol HistoryLocationToInteractorProtocol: class {
    
}
