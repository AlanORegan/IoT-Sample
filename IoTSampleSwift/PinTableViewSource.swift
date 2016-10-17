//
//  pinTableViewSource.swift
//  RaspMultipin
//
//  Created by Alan O'Regan on 2015/12/14.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import UIKit


// typealiases used to create interface templates between Cell template class and pin
//typealias CellHandler = (pinNumber: Int, status : Bool) -> Void
//typealias ModelHandler = (setting : String, CellHandler) -> Void

class PinTableViewSource : NSObject, UITableViewDataSource {
    
    //MARK: Properties
    
    var pins = [Pin]()
    
    var tableViewRefreshDelegate: TableViewRefreshProtocol?
    
    var initialRefresh = 0
    
    var firstLoad = true
    
    //MARK: Initialisers
    
    override init() {
        
        // Invoke the Superclass initialiser
        
        super.init()
        
        // Get the pin layout from the Server
        
        self.loadData()
        AWSApiManager.sharedInstance.pinsCallback = HandleDataDelta
    }
    
    func loadData() {
//        RestApiManager.sharedInstance.getStatus(handleResponse)
        
        AWSApiManager.sharedInstance.getCallbackAcceptedData(HandleDataAccepted)
        if !firstLoad {
            AWSApiManager.sharedInstance.getThingState();
        } else {
            firstLoad = false
        }
    }
    
    //MARK: Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 // This was put in mainly for my own unit testing
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count // Most of the time my data source is an array of something...  will replace with the actual name of the data source
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        // Note:  Be sure to replace the argument to dequeueReusableCellWithIdentifier with the actual identifier string ("pinCell") to allow reuse!
        
        if (pins[row].pinType == "Switch") {
            let cell = tableView.dequeueReusableCellWithIdentifier("pinCellSw", forIndexPath: indexPath) as! PinTableViewCellSw
        
            // set cell's properties
        
            cell.pinCellDisplayNumber.text = pins[row].displayName
            cell.pinCellName.text = pins[row].name
            cell.pinCellSwitch.setOn(pins[row].status, animated: false)
            cell.pinCellNumber = pins[row].pinNumber
        
            //Hook up the delegate for model updates
        
            cell.modelDelegate(pins[row].updatePin)
            
            return cell
            
        } else /* if (pins[row].pinType == "Dimmer") */ {
            let cell = tableView.dequeueReusableCellWithIdentifier("pinCellDim", forIndexPath: indexPath) as! PinTableViewCellDim
            
            // set cell's properties
            
            cell.pinCellDisplayNumber.text = pins[row].displayName
            cell.pinCellName.text = pins[row].name
            cell.pinCellNumber = pins[row].pinNumber
            
            //Hook up the delegate for model updates
            
            cell.modelDelegate(pins[row].setPinForTime)
            
            return cell

        }
        
        //print("Cell \(row) pin Number \(cell.pinCellNumber.text)\n")
        
    }
    
    //Define a reusable function for handling responses from the multipin API
    
    private func HandleDataAccepted(thingName: String, json: JSON, payloadString: String) {
//        guard let data:JSON = JSON(data: payloadString!) else {
//            print("\(callType) call to \(path) response data could not be converted to JSON.\n")
//            return
//        }
        print("PinTableSource Delta: \(thingName) data: \(payloadString)")
        for devicepin in json["state"]["reported"] {
            
            let number = Int(devicepin.0)!//devicepin.1["pinNumber"].int!
            
            let name = devicepin.1["pinName"].stringValue
            
            let shortName = devicepin.1["pinShortName"].stringValue
            
            let status = devicepin.1["pinStatus"].bool!
            
            let pinType = devicepin.1["pinType"].stringValue
            
            let pin = Pin(number: number, name: name, shortName: shortName, status: status, pinType: pinType)
            
            
            //print("pin Number \(pin.number) pin Name \(pin.name) pin Status \(pin.status) Devicepin \(devicepin)\n")
            
            if let found = pins.indexOf({$0.pinNumber == pin.pinNumber}) {
                
                pins[found] = pin
                
            } else {
                
                pins.append(pin)
            }
        }
        
        //overwrite the reported with the desired status if pin present in desired
        for devicepin in json["state"]["desired"] {
            
            let number = Int(devicepin.0)!
            
            if let found = pins.indexOf({$0.pinNumber == number}) {
                if devicepin.1["pinStatus"] != nil {
                    pins[found].status = devicepin.1["pinStatus"].bool!
                }
            }
        }
        
        //Sort the pins based on the Settings parameters
        
        sortpinsByAttribute()
        
        //Doing this causes the table to refresh
        
        tableViewRefreshDelegate?.refreshView(1)
    }
    
    private func HandleDataDelta(thingName: String, json: JSON, payloadString: String) {
        //        guard let data:JSON = JSON(data: payloadString!) else {
        //            print("\(callType) call to \(path) response data could not be converted to JSON.\n")
        //            return
        //        }
        print("PinTableSource Data Delta: \(thingName) data: \(json)")
        for devicepin in json["state"] {
            
            let pinNumber = Int(devicepin.0)!//devicepin.1["pinNumber"].int!
            
            //print("pin Number \(pin.number) pin Name \(pin.name) pin Status \(pin.status) Devicepin \(devicepin)\n")
            
            if let found = pins.indexOf({$0.pinNumber == pinNumber}) {
                
                let pin = pins[found]
                
                if devicepin.1["pinName"] != nil {
                    pin.name = devicepin.1["pinName"].stringValue
                }
                
                if devicepin.1["pinShortName"] != nil {
                    pin.shortName = devicepin.1["pinShortName"].stringValue
                }
                
                if devicepin.1["pinStatus"] != nil {
                    pin.status = devicepin.1["pinStatus"].bool!
                }
                
                if devicepin.1["pinType"] != nil {
                    pin.pinType = devicepin.1["pinType"].stringValue
                }
                
                pins[found] = Pin(number: pin.pinNumber, name: pin.name, shortName: pin.shortName, status: pin.status, pinType: pin.pinType)
                
            } else {
                
                // create new pin with info provided
                let number = pinNumber
                
                var name = ""
                if devicepin.1["pinName"] != nil {
                    name = devicepin.1["pinName"].stringValue
                }
                
                var shortName = ""
                if devicepin.1["pinShortName"] != nil {
                    shortName = devicepin.1["pinShortName"].stringValue
                }
                
                var status = false
                if devicepin.1["pinStatus"] != nil {
                    status = devicepin.1["pinStatus"].bool!
                }
                
                var pinType = ""
                if devicepin.1["pinType"] != nil {
                    pinType = devicepin.1["pinType"].stringValue
                }
                
                let pin = Pin(number: number, name: name, shortName: shortName, status: status, pinType: pinType)
                
                pins.append(pin)
            }
        }
        
        //Sort the pins based on the Settings parameters
        
        sortpinsByAttribute()
        
        //Doing this causes the table to refresh
        
        tableViewRefreshDelegate?.refreshView(1)
    }
    
    private func handleResponse(path : String, callType : String, data : NSData?, response : NSURLResponse?, error: NSError?) -> Void {
        
        
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
        
        //Check if the json is empty
        
        if json.isEmpty {
            print("\(callType) call to \(path) returned and empty data response.\n")
            return
        }
        
        // Unwrap the json data (response, status of the pin, error description) and handle response
        
        guard let pinResponse : String = json["response"].rawString()!.lowercaseString else {
            print("\(callType) call to \(path) did not provide a response.\n")
            return
        }
        
        //print("pin Response \(pinResponse)\n")
            
        switch pinResponse {
            
        case "fail":
            
            guard let errorDescription : String = json["error"].rawValue as? String else {
//                print("\(callType) call to \(sharedAppSettings.baseUrlpin) failed but did not return the error description.\n")
                return
            }
            print("\(callType) call to \(path) returned error: \(errorDescription)\n")
            print("Response: \(response)\nError: \(errorDescription)\n")
            
        case "ok":
            
            //Read the responses into the model, adding if there are new pins
            
            for devicepin in json["pins"] {
                
                let number = devicepin.1["pinNumber"].int!
                
                let name = devicepin.1["pinName"].stringValue
                
                let shortName = devicepin.1["pinShortName"].stringValue
                
                let status = devicepin.1["pinStatus"].bool!
                
                let pinType = devicepin.1["pinType"].stringValue
                
                let pin = Pin(number: number, name: name, shortName: shortName, status: status, pinType: pinType)
                
                
                //print("pin Number \(pin.number) pin Name \(pin.name) pin Status \(pin.status) Devicepin \(devicepin)\n")
            
                if let found = pins.indexOf({$0.pinNumber == pin.pinNumber}) {
                
                    pins[found] = pin
                
                } else {
            
                    pins.append(pin)
                }
            }
            
            //Sort the pins based on the Settings parameters
            
            sortpinsByAttribute()
            
            //Doing this causes the table to refresh
            
            tableViewRefreshDelegate?.refreshView(1)
            
        default:
            
            print("\(callType) call to \(path) returned an unexpected response: \(response).\n")
            
        }
        
    }
    
    func sortpinsByAttribute() {
        
        print("Settings \(sharedAppSettings.pinsSortedBy) \(sharedAppSettings.pinsSortOrder).\n")
        
        switch sharedAppSettings.pinsSortedBy {
            case "pinNumber" :
                switch sharedAppSettings.pinsSortOrder {
                    case "Ascending" :
                        pins.sortInPlace({$0.pinNumber < $1.pinNumber})
                    case "Descending" :
                        pins.sortInPlace({$0.pinNumber > $1.pinNumber})
                    default:
                        return
                }
            case "pinShortName" :
                switch sharedAppSettings.pinsSortOrder {
                case "Ascending" :
                    pins.sortInPlace({$0.shortName < $1.shortName})
                case "Descending" :
                    pins.sortInPlace({$0.shortName > $1.shortName})
                default:
                    return
            }
            case "pinName" :
                switch sharedAppSettings.pinsSortOrder {
                    case "Ascending" :
                        pins.sortInPlace({$0.name < $1.name})
                    case "Descending" :
                        pins.sortInPlace({$0.name > $1.name})
                    default:
                        return
                }
            default:
                return
        }
    }
    
    func sortpinsBy(a : AnyObject, b : AnyObject, ascending : Bool) {
        
        for pin in 0...pins.count-2 {
            
            if sharedAppSettings.pinsSortedBy == "1" {
                
                // Sort by Number
                
                if pins[pin].pinNumber > pins[pin+1].pinNumber {
                    swap(&pins[pin], &pins[pin+1])
                }
            } else {
                
                // Sort by Name
                
                if pins[pin].name > pins[pin+1].name {
                    swap(&pins[pin], &pins[pin+1])
                }
            }
        }

    }
    
}
