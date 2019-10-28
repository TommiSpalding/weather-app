//
//  Weather.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 11/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//
import Foundation

class Weather : NSObject, NSCoding {

    var cityName : String?
    var temperature : Double?
    var weatherIconName : String?
    var weatherDescription : String?
    var date : Date?
    var created : Date = Date(timeIntervalSinceNow: 0)
    
    func setDate(dateText: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = formatter.date(from: dateText) {
            self.date = date
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        cityName = aDecoder.decodeObject(forKey: "cityName") as? String
        temperature = aDecoder.decodeObject(forKey: "temperature") as? Double
        weatherIconName = aDecoder.decodeObject(forKey: "weatherIconName") as? String
        weatherDescription = aDecoder.decodeObject(forKey: "weatherDescription") as? String
        date = aDecoder.decodeObject(forKey: "date") as? Date
        if let cdate = aDecoder.decodeObject(forKey: "created") as? Date {
            created = cdate
        }
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cityName, forKey: "cityName")
        aCoder.encode(temperature, forKey: "temperature")
        aCoder.encode(weatherIconName, forKey: "weatherIconName")
        aCoder.encode(weatherDescription, forKey: "weatherDescription")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(created, forKey: "created")
    }
}
