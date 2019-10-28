//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 11/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject,  CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var completionHandler : ((String?) -> ())?
    
    func getCurrentLocationCityName(completionHandler: @escaping ((String?) -> ())) {
        self.completionHandler = completionHandler
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        NSLog("started updating locations")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations: [CLLocation]) {
        NSLog("got location data")
        if didUpdateLocations.count < 1 {
            return
        }
        manager.stopUpdatingLocation()
    
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(didUpdateLocations[0]) { (placemarks, error) in
            if let cityname = placemarks?.first?.locality {
                if let handler = self.completionHandler {
                    handler(self.fixCityName(cityName: cityname))
                    self.completionHandler = nil
                }
            } else {
                NSLog("Error: couldn't get your current location")
                if let handler = self.completionHandler {
                    handler(nil)
                    self.completionHandler = nil
                }
            }
        }
    }
    
    private func fixCityName(cityName: String) -> String {
        return cityName.replacingOccurrences(of: " ", with: "+").lowercased()
    }
}
