//
//  Forecast.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 25/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import Foundation

class Forecast : NSObject, NSCoding {
    
    var weatherList : [Weather]
    var created : Date
    var cityName : String?
    
    override init() {
        self.weatherList = []
        created = Date(timeIntervalSinceNow: 0)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        weatherList = aDecoder.decodeObject(forKey: "weatherList") as! [Weather]
        created = aDecoder.decodeObject(forKey: "created") as! Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(weatherList, forKey: "weatherList")
        aCoder.encode(created, forKey: "created")
    }
    
    func sortByDate() {
        weatherList.sort(by: {
            if let d1 = $0.date, let d2 = $1.date {
                return d1.compare(d2) == .orderedAscending
            }
            return false
        })
    }
}
