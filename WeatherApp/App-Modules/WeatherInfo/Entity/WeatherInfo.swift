//
//  WeatherInfo.swift
//  WeatherApp
//
//  Created by Chaithra T V on 17/02/20.
//  Copyright © 2020 Chaithra TV. All rights reserved.
//

import Foundation

struct WeatherDescription:Codable {
    
    var id: Int
    var main: String
    var description: String
    var icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case main = "main"
        case description = "description"
        case icon = "icon"
    }
}

struct WeatherInfo: Codable{
    
    let data: [WeatherDescription]
    var temp: Double
    var tempMin: Double
    var tempMax: Double
    var humidity: Double
    var place: String
    var pressure: Int
    var sunrise: Int
    var sunset: Int
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case weather = "weather"
        case main = "main"
        case place = "name"
        case humidity = "humidity"
        
        case sys = "sys"
        case sunrise = "sunrise"
        case sunset = "sunset"
        case pressure = "pressure"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        place = try container.decode(String.self, forKey: .place)
        data = try container.decode([WeatherDescription].self, forKey: .weather)
        
        let temperatures = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .main)
        temp = try temperatures.decode(Double.self, forKey: .temp)
        tempMin = try temperatures.decode(Double.self, forKey: .tempMin)
        tempMax = try temperatures.decode(Double.self, forKey: .tempMax)
        humidity = try temperatures.decode(Double.self, forKey: .humidity)
        pressure = try temperatures.decode(Int.self, forKey: .pressure)

        let sys = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .sys)
        sunrise = try sys.decode(Int.self, forKey: .sunrise)
        sunset = try sys.decode(Int.self, forKey: .sunset)
    }
    
    
    func encode(to encoder: Encoder) throws {
        
    }
}
