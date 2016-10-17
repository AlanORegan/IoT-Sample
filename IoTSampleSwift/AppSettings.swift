//
//  AppSettings.swift
//  Raspiot
//
//  Created by Alan O'Regan on 2015/10/20.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import Foundation

class AppSettings {
    
    //var appDefaults = Dictionary<String, AnyObject>()
    
    var baseUrlPin : String = ""
    
    var baseUrl : String = ""
    
    var basePin : String = ""
    
    var accountNumber : String = ""
        
    var baseUrlTimeout : NSTimeInterval = 30
    
    var pinsDisplayName : String = ""
    
    var pinsSortedBy : String = ""
    
    var pinsSortOrder : String = ""
    
    init() {
        
        //if it is ever necessary to change app defaults from within the app:
        // NSUserDefaults.standardUserDefaults().registerDefaults(appDefaults)
        
        
        // Read USER application settings (from root.plist)
        
        //NSUserDefaults.standardUserDefaults().registerDefaults()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // IP Configuration
    
        guard let base_Url: String = defaults.stringForKey("base_Url") else {
            print("Setting for base_Url could not be found.\n")
            return
        }
        
        baseUrl = base_Url
        
        guard let base_Pin = defaults.stringForKey("base_Pin") else {
            print("Setting for base_Pin could not be found.\n")
            return
        }
        
        basePin = base_Pin
    
        baseUrlPin = base_Url + base_Pin
        
        guard let account_Number: String = defaults.stringForKey("account_Number") else {
            print("Setting for account_Number could not be found.\n")
            return
        }
        
        accountNumber = account_Number
        
        // Display Defaults
        
        if let pins_Display_Name : String = defaults.stringForKey("pins_Display_Name") {
            pinsDisplayName = pins_Display_Name
        } else {
            print("Setting for pins_Display_Name could not be found, using default.\n")
            pinsDisplayName = "pinNumber"
        }
        
        if let pins_Sorted_By : String = defaults.stringForKey("pins_Sorted_By") {
            pinsSortedBy = pins_Sorted_By
        } else {
            print("Setting for pins_Sorted_By could not be found, using default.\n")
            pinsSortedBy = "pinNumber"
        }
        
        
        if let pins_Sort_Order : String = defaults.stringForKey("pins_Sort_Order") {
            pinsSortOrder = pins_Sort_Order
        } else {
            print("Setting for pins_Sort_Order could not be found, using default.\n")
            pinsSortOrder = "Ascending"
        }
        
        //read FIXED application configuration settings (from config.plist)
        
        //Retrieve config dictionary from application config file

        guard let configPath : String = NSBundle.mainBundle().pathForResource("Config", ofType: "plist") else {
            print("Error: could not find config file.\n")
            return
        }
        
        let appConfigDict = NSDictionary(contentsOfFile : configPath)
        
        guard let appConfig : NSDictionary = appConfigDict!.valueForKey("AppConfig") as? NSDictionary else {
            print("Error: could not find App Config")
            return
        }
        
        //Extract the config file parameters from the dictionary here
        
        baseUrlTimeout = appConfig.valueForKey("base_url_timeout") as! NSTimeInterval
    }
}

let sharedAppSettings = AppSettings()