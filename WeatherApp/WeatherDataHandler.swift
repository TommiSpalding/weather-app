//
//  WeatherDataHandler.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 10/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import Foundation

class WeatherDataHandler : NSObject, NSCoding {
    
    private var weatherDataFetcher : WeatherDataFetcher = WeatherDataFetcher()
    private var locationManager : LocationManager = LocationManager()
    var currentCity : String = ""
    
    required init?(coder aDecoder: NSCoder) {
        if let cityname = aDecoder.decodeObject(forKey: "currentCity") as? String {
            currentCity = cityname
        }
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(currentCity, forKey: "currentCity")
    }
    
    func getWeather(completionHandler: @escaping ((Weather?) -> ())) {
        if currentCity == "" {
            getCurrentLocationWeather(completionHandler: completionHandler)
        } else {
            getCityWeather(cityName: currentCity, completionHandler: completionHandler)
        }
    }
    
    func getForecast(completionHandler: @escaping ((Forecast?) -> ())) {
        if currentCity == "" {
            getCurrentLocationForecast(completionHandler: completionHandler)
        } else {
            getCityForecast(cityName: currentCity, completionHandler: completionHandler)
        }
    }
    
    func getCurrentLocationWeather(completionHandler: @escaping ((Weather?) -> ())) {
        locationManager.getCurrentLocationCityName(completionHandler: { (cityName) in
            if let cityName = cityName {
                self.currentCity = cityName
                self.getCityWeather(cityName: cityName, completionHandler: completionHandler)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func getCurrentLocationForecast(completionHandler: @escaping ((Forecast?) -> ())) {
        locationManager.getCurrentLocationCityName(completionHandler: { (cityName) in
            if let cityName = cityName {
                self.currentCity = cityName
                self.getCityForecast(cityName: cityName, completionHandler: completionHandler)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func setCityToCurrentLocation() {
        locationManager.getCurrentLocationCityName { (cityName) in
            if let cityName = cityName {
                self.currentCity = cityName
            }
        }
    }
    
    func getCityWeather(cityName: String, completionHandler: @escaping ((Weather?) -> ())) {
        if let cachedWeather = loadWeatherDataFromCache(cityName: cityName), cachedWeather.created.timeIntervalSinceNow > -300 {
            completionHandler(cachedWeather)
        } else {
            weatherDataFetcher.getCityWeather(cityName: cityName, completionHandler: { (weatherData) in
                NSLog("got into the callback function")
                if let weatherData = weatherData, let weatherResponse = self.parseWeatherData(weatherData: weatherData) {
                    self.saveWeatherToCache(cityName: cityName, weather: weatherResponse)
                    completionHandler(weatherResponse)
                } else {
                    NSLog("Error with parsing weather data.")
                    completionHandler(nil)
                }
            })
        }
    }
    
    func getCityForecast(cityName: String, completionHandler: @escaping ((Forecast?) -> ())) {
        if let cachedForecast = loadForecastDataFromCache(cityName: cityName), cachedForecast.created.timeIntervalSinceNow > -300 {
            completionHandler(cachedForecast)
        } else {
            weatherDataFetcher.getCityForecast(cityName: cityName) { (forecastData) in
                if let forecastData = forecastData, let forecastResponse = self.parseForecastData(forecastData: forecastData) {
                    completionHandler(forecastResponse)
                } else {
                    NSLog("Error with parsing weather data.")
                    completionHandler(nil)
                }
            }
        }
    }
    
    private func parseWeatherData(weatherData: Data) -> Weather? {
        do {
            let json = try JSONSerialization.jsonObject(with: weatherData, options: [])
            let weatherResponse = Weather()
            if let dictionary = json as? NSDictionary {
                if let main = dictionary["main"] as? NSDictionary,
                  let temperature = main["temp"] as? Double {
                    weatherResponse.temperature = temperature
                } else {
                    print(json)
                    NSLog("Error finding the temperature from the JSON")
                    return nil
                }
                if let cityName = dictionary["name"] as? String {
                    weatherResponse.cityName = cityName
                } else {
                    print(json)
                    NSLog("Error finding the cityname from the JSON")
                    return nil
                }
                if let w = dictionary["weather"] as? [NSDictionary],
                 let weatherIconName = w[0]["icon"] as? String,
                 let weatherDescription = w[0]["description"] as? String{
                    weatherResponse.weatherIconName = weatherIconName
                    weatherResponse.weatherDescription = weatherDescription
                } else {
                    print(json)
                    NSLog("Error finding the weather icon / description from the JSON")
                    return nil
                }
                
                return weatherResponse
            } else {
                NSLog("Error casting json to dictionary")
            }
            
        } catch let parsingError {
            NSLog("Error with parsing Json: " + parsingError.localizedDescription)
        }
        
        return nil
    }
    
    func parseForecastData(forecastData: Data) -> Forecast? {
        do {
            let json = try JSONSerialization.jsonObject(with: forecastData, options: [])
            let forecastResponse = Forecast()
            if let dictionary = json as? NSDictionary, let weatherList = dictionary["list"] as? [NSDictionary] {
                var cityName : String?
                if let city = dictionary["city"] as? NSDictionary, let name = city["name"] as? String {
                    cityName = name
                    forecastResponse.cityName = name
                } else {
                    print(json)
                    NSLog("Error finding the cityname from the JSON")
                }
                for (item) in weatherList {
                    let weather = Weather()
                    if let main = item["main"] as? NSDictionary,
                        let temperature = main["temp"] as? Double {
                        weather.temperature = temperature
                    } else {
                        print(item)
                        NSLog("Error finding the temperature from the JSON")
                    }
                    if let name = cityName {
                        weather.cityName = name
                    }
                    if let w = item["weather"] as? [NSDictionary],
                        let weatherIconName = w[0]["icon"] as? String,
                        let weatherDescription = w[0]["description"] as? String{
                        weather.weatherIconName = weatherIconName
                        weather.weatherDescription = weatherDescription
                    } else {
                        print(json)
                        NSLog("Error finding the weather icon / description from the JSON")
                    }
                    if let dateText = item["dt_txt"] as? String {
                        weather.setDate(dateText: dateText)
                    } else {
                        print(item)
                        NSLog("Error finding the date text from the JSON")
                    }
                    
                    forecastResponse.weatherList.append(weather)
                }
                
                forecastResponse.sortByDate()
                return forecastResponse
            } else {
                NSLog("Error casting json to dictionary")
            }
            
        } catch let parsingError {
            NSLog("Error with parsing Json: " + parsingError.localizedDescription)
        }
        
        
        return nil
    }
    
    private func saveWeatherToCache(cityName: String, weather : Weather) {
        let pathWithFileName = getCacheFilePath(fileName: cityName + "Weather")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: weather, requiringSecureCoding: false)
            
            try data.write(to: URL(fileURLWithPath: pathWithFileName))
        } catch {
            NSLog("Error writing weather data to cache")
        }
    }
    
    private func loadWeatherDataFromCache(cityName: String) -> Weather? {
        let pathWithFileName = getCacheFilePath(fileName: cityName + "Weather")
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathWithFileName))
            
            let weather = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Weather
            return weather
        } catch {
            
        }
        
        return nil
    }
    
    private func saveForecastToCache(cityName: String, forecast : Forecast) {
        let pathWithFileName = getCacheFilePath(fileName: cityName + "Forecast")
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: forecast, requiringSecureCoding: false)
            
            try data.write(to: URL(fileURLWithPath: pathWithFileName))
        } catch {
            NSLog("Error writing forecast data to cache")
        }
    }
    
    private func loadForecastDataFromCache(cityName: String) -> Forecast? {
        let pathWithFileName = getCacheFilePath(fileName: cityName + "Forecast")
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathWithFileName))
            
            let forecast = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Forecast
            return forecast
        } catch {
            
        }
        
        return nil
    }
    
    private func getCacheFilePath(fileName: String) -> String {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        
        let documentDirectory = documentDirectories[0]
        let pathWithFileName = documentDirectory + "/" + fileName
        
        return pathWithFileName
    }
}
