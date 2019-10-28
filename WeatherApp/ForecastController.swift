//
//  ForecastController.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 10/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import UIKit

class ForecastController : UITableViewController {
    
    var weatherDataHandler : WeatherDataHandler?
    var forecastData : Forecast?
    
    @IBOutlet weak var uiActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentTabController = self.tabBarController as? MainTabBarController, let handler = parentTabController.weatherDataHandler {
            weatherDataHandler = handler
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        uiActivityIndicatorView.startAnimating()
        weatherDataHandler?.getForecast(completionHandler: { (weatherData) in
            if let weatherData = weatherData {
                self.forecastData = weatherData
                DispatchQueue.main.async(execute: {() in
                    self.tableView.reloadData()
                    if let cityName = weatherData.cityName {
                        self.titleLabel.text = "Forecast for " + cityName
                    }
                    self.uiActivityIndicatorView.stopAnimating()
                })
            } else {
                DispatchQueue.main.async(execute: {() in
                    self.uiActivityIndicatorView.stopAnimating()
                    Tools.displayError(message: "Failed to fetch forecast data.", controller: self)
                })
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self.forecastData {
            return data.weatherList.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "forecastID")
        
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "forecastID")
        }
        
        if let forecast = forecastData?.weatherList[indexPath.row] {
            if let temp = forecast.temperature, let desc = forecast.weatherDescription {
                var tempText : String
                if temp >= 0 {
                    tempText = "+" + String(temp)
                } else {
                    tempText = String(temp)
                }
                cell?.textLabel?.text = tempText + " C° | " + desc
            }
            if let date = forecast.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yy, H:mm a"
                formatter.amSymbol = "AM"
                formatter.pmSymbol = "PM"
                cell?.detailTextLabel?.text = formatter.string(from: date)
            }
            if let imageName = forecast.weatherIconName, let image = UIImage(named: imageName + "s") {
                cell?.imageView?.image = image
            }
        }
        
        return cell!
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
