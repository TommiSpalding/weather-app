//
//  WeatherDataFetcher.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 10/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import Foundation

// api key de093aff2e68ddc240d37192823e1bbe

// api.openweathermap.org/data/2.5/weather?q=tampere&APPID=

// api.openweathermap.org/data/2.5/weather?q=tampere&APPID=de093aff2e68ddc240d37192823e1bbe

class WeatherDataFetcher {
    
    private let APIKEY : String = "de093aff2e68ddc240d37192823e1bbe"
    private let APIURL : String = "https://api.openweathermap.org/data/2.5/"
    private let WEATHERSTRING : String = "weather?q="
    private let FORECASTSTRING : String = "forecast?q="
    private let OPTIONSSTRING : String = "&units=metric&APPID="
    
    private var completionHandler : ((Data?) -> ())?
    
    func getCityWeather(cityName: String, completionHandler: @escaping (Data?) -> ()) {
        self.completionHandler = completionHandler
        let url = APIURL + WEATHERSTRING + fixCityName(cityName: cityName) + OPTIONSSTRING + APIKEY
        fetchUrl(url: url)
    }
    
    func getCityForecast(cityName: String, completionHandler: @escaping (Data?) -> ()) {
        self.completionHandler = completionHandler
        let url = APIURL + FORECASTSTRING + fixCityName(cityName: cityName) + OPTIONSSTRING + APIKEY
        fetchUrl(url: url)
    }

    
    private func fetchUrl(url: String) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if let url = URL(string: url) {
            let task = session.dataTask(with: url, completionHandler: doneFetching)
            task.resume()
        } else {
            NSLog("Error: invalid URL: " + url)
            if let handler = self.completionHandler {
                handler(nil)
                self.completionHandler = nil
            }
        }
        
    }
    
    private func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            if let handler = self.completionHandler {
                handler(data)
                self.completionHandler = nil
            }
        } else {
            NSLog("Error: no data from api fetch")
            if let handler = self.completionHandler {
                handler(nil)
                self.completionHandler = nil
            }
        }
        /*
        if let response = response {
            // do something
        }
        */
        if let error = error {
            NSLog("Error with fetching: " + error.localizedDescription)
            if let handler = self.completionHandler {
                handler(nil)
                self.completionHandler = nil
            }
        }
    }
    
    private func fixCityName(cityName: String) -> String {
        return cityName.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "ä", with: "a").replacingOccurrences(of: "ö", with: "o").lowercased()
    }
}
