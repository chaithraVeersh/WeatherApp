//
//  Extension.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
     func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}

extension Int {
    func getTimeFromInterval() -> String{
        let  sunrise = Date(timeIntervalSinceReferenceDate: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let time = formatter.string(from: sunrise)
        return time
    }
}
