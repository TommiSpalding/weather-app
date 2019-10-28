//
//  CurrentWeatherController.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 10/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import UIKit
import Foundation

class CurrentWeatherController : UIViewController {
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var uiActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    var weatherDataHandler : WeatherDataHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parentTabController = self.tabBarController as? MainTabBarController {
            weatherDataHandler = parentTabController.weatherDataHandler
        }
        
        //weatherDataHandler?.getCityWeather(cityName: "san fransisco", completionHandler: parseWeatherResponse)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uiActivityIndicatorView.startAnimating()
        weatherDataHandler?.getWeather(completionHandler: parseWeatherResponse)
    }
    
    func parseWeatherResponse(weather: Weather?) {
        if let weather = weather {
            DispatchQueue.main.async(execute: {() in
                if let temp = weather.temperature {
                    self.temperatureLabel.text = String(temp) + " C°"
                }
                if let name = weather.cityName {
                    self.cityNameLabel.text = name
                }
                if let iconName = weather.weatherIconName {
                    self.changeWeatherIcon(iconName: iconName)
                }
                if let weatherDescription = weather.weatherDescription {
                    self.weatherDescriptionLabel.text = weatherDescription
                }
                self.uiActivityIndicatorView.stopAnimating()
            })
        } else {
            DispatchQueue.main.async(execute: {() in
                self.uiActivityIndicatorView.stopAnimating()
                Tools.displayError(message: "Failed to fetch weather data.", controller: self)
            })
        }
    }
    
    func changeWeatherIcon(iconName: String) {
        if let image = UIImage(named: iconName) {
            weatherIcon.image = image
        } else {
            NSLog("Error changing weather icon: no such image name")
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        if let parentTabController = self.tabBarController as? MainTabBarController {
            weatherDataHandler = parentTabController.weatherDataHandler
        }
        
        super.decodeRestorableState(with: coder)
    }
}
