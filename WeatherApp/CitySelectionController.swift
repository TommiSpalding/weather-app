//
//  CitySelectionController.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 10/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import UIKit

class CitySelectionController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeCityButton: UIButton!
    @IBOutlet weak var uiActivityIndicatorView: UIActivityIndicatorView!
    
    var weatherDataHandler : WeatherDataHandler?
    var cities : [String] = ["Use GPS", "Turku"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentTabController = self.tabBarController as? MainTabBarController {
            weatherDataHandler = parentTabController.weatherDataHandler
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let handler = self.weatherDataHandler {
            if indexPath.row > 0 {
                handler.currentCity = cities[indexPath.row]
            } else {
                handler.currentCity = ""
                handler.setCityToCurrentLocation()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cityID")
        
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cityID")
        }
        
        cell?.textLabel?.text = cities[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.item > 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
        } else if editingStyle == .insert {
            
        }
    }
    
    
    @IBAction func addCityButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add a City", message: "Please type in the name of the city", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "City name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if let handler = self.weatherDataHandler, let text = alert.textFields?.first?.text {
                self.uiActivityIndicatorView.startAnimating()
                handler.getCityWeather(cityName: text, completionHandler: { (weatherResponse) in
                    if weatherResponse != nil {
                        DispatchQueue.main.async(execute: {() in
                            self.cities.append(text)
                            self.tableView.reloadData()
                            self.uiActivityIndicatorView.stopAnimating()
                        })
                    } else {
                        DispatchQueue.main.async(execute: {() in
                            self.uiActivityIndicatorView.stopAnimating()
                            Tools.displayError(message: "Could not find a city named " + text, controller: self)
                        })
                    }
                })
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func removeCityButtonPressed(_ sender: Any) {
        if !tableView.isEditing {
            tableView.setEditing(true, animated: true)
            removeCityButton.setTitle("Stop Removing", for: .normal)
        } else {
            tableView.setEditing(false, animated: true)
            removeCityButton.setTitle("Remove City", for: .normal)
        }
        
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.cities, forKey: "cityList")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        if let cityList = coder.decodeObject(forKey: "cityList") as? [String] {
            self.cities = cityList
        }
        
        if let parentTabController = self.tabBarController as? MainTabBarController {
            weatherDataHandler = parentTabController.weatherDataHandler
        }

        super.decodeRestorableState(with: coder)
    }
    
}
