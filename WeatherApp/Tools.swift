//
//  Tools.swift
//  WeatherApp
//
//  Created by Thomas Spalding on 28/10/2019.
//  Copyright © 2019 Thomas Spalding. All rights reserved.
//

import Foundation
import UIKit

class Tools {
    static func displayError(message: String, controller : UIViewController) {
        let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        controller.present(alert, animated: true, completion: nil)
    }
}
