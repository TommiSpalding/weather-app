//
//  MainTabBarController.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 25/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import UIKit

class MainTabBarController : UITabBarController {
    
    var weatherDataHandler : WeatherDataHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let handler = delegate.weatherDataHandler {
            self.weatherDataHandler = handler
        }
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.weatherDataHandler, forKey: "weatherDataHandler")
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        if let handler = coder.decodeObject(forKey: "weatherDataHandler") as? WeatherDataHandler {
            self.weatherDataHandler = handler
        }
        
        super.decodeRestorableState(with: coder)
    }
}
