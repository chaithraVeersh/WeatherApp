//
//  History.swift
//  WeatherApp
//
//  Created by Chaithra T V on 20/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import RealmSwift


class History: Object {
    
    @objc dynamic var placeName = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
}
