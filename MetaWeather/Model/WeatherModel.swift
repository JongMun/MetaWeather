//
//  WeatherModel.swift
//  MetaWeather
//
//  Created by 정종문 on 2021/01/18.
//

import Foundation

struct Country : Codable {
    let title: String?
    let location_type: String?
    let woeid: Int?
    let latt_long: String?
}

struct Weather : Codable {
    let title : String!
    let created: Date!
    let weather_state_name: String!
    let weather_state_abbr: String!
    let the_temp: Double!
    let humidity: Double!
}

struct WeatherDetail : Codable {
    let created: String?
    let weather_state_name: String?
    let weather_state_abbr: String?
    let the_temp: Double?
    let humidity: Double?
}
