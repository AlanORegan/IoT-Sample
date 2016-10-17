//
//  Pin.swift
//  RaspMultiPin
//
//  Created by Alan O'Regan on 2015/12/12.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import UIKit
//import AWSIoT

class Pin {
    // MARK: Properties
    
    var pinNumber : Int
    
    var name : String
    
    var shortName : String
    
    var displayName : String
    
    var status : Bool
    
    var cellHandler : CellHandler?
    
    // MARK: Initiaitalizers
    
    init(number: Int, name : String, shortName : String, status : Bool) {
        
        //initialise stored properties
        
        self.pinNumber = number
        self.name = name
        self.shortName = shortName
        self.status = status
        
        if sharedAppSettings.pinsDisplayName == "pinNumber" {
            self.displayName = String(number)
        } else {
            self.displayName = shortName
        }
        
    }
    
    init() {
        //initialise stored properties
        
        self.pinNumber = 0
        self.name = ""
        self.shortName = ""
        self.status = true
        self.displayName = ""
    }
    
    func updatePin(requestedPinSetting: String, cellHandler : CellHandler) {
        
        self.cellHandler = cellHandler
        
//        RestApiManager.sharedInstance.setPinStatus(self.pinNumber, requestedPinSetting: requestedPinSetting, onCompletion: handlePinResponse)
        print("\(requestedPinSetting)")
        
        //let iotDataManager = AWSIoTDataManager.defaultIoTDataManager()
        
        AWSApiManager.sharedInstance.iotDataManager.publishString("\(requestedPinSetting)", onTopic:thingName, qoS:.MessageDeliveryAttemptedAtMostOnce)
        
        
        if (!AWSApiManager.sharedInstance.operationInProgress)
        {
            AWSApiManager.sharedInstance.setPinStatus(pinNumber, requestedPinSetting: requestedPinSetting)
            self.status = ("on" == requestedPinSetting)
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {
                self.cellHandler!(pinNumber: self.pinNumber, status: self.status)})    // cancel the operation
            print("Switch operation cancelled")
        }

    }
    
    private func handlePinResponse(path : String, callType : String, data : NSData?, response : NSURLResponse?, error: NSError?) -> Void {
        
        // Check for an error response form the API call
        
        guard error == nil else {
            print("\(callType) call to \(path) returned error: \(error!.localizedDescription)")
            return
        }
        
        // Convert the data to json
        
        guard let json:JSON = JSON(data: data!) else {
            print("\(callType) call to \(path) response data could not be converted to JSON.\n")
            return
        }
        
        // Check if the json is empty
        
        if json.isEmpty {
            print("\(callType) call to \(sharedAppSettings.baseUrlPin) returned and empty data response.\n")
            return
        }
        
        // Unwrap the json data (response, status of the PIN, error description) and handle response
        
        guard let pinResponse : String = json["response"].rawString()!.lowercaseString else {
            print("\(callType) call to \(path) did not provide a response.\n")
            return
        }
        
        switch pinResponse {
            
        case "fail":
            
            guard let errorDescription : String = json["error"].rawValue as? String else {
                print("\(callType) call to \(path) failed but did not return the error description.\n")
                return
            }
            print("\(callType) call to \(path) returned error: \(errorDescription)\n")
            print("Response: \(response)\n")
            
            // reset the switch value because the call failed
            
            dispatch_async(dispatch_get_main_queue(), {
                self.cellHandler!(pinNumber: self.pinNumber, status: self.status)})
            
        case "ok":
            
            guard let status : Bool = json["status"].rawValue as? Bool else {
                print("\(callType) call to \(path) succeeded but did not return the PIN status.\n")
                return
            }
            
            //Update the model with the returned Pi status for the pin
            
            self.status = status
            
        default:
            
            print("\(callType) call to \(path) returned an unexpected response: \(response).\n")
            
        }
    }
    
}
