//
//  RestApiManager.swift
//  Raspiot
//
//  Created by Alan O'Regan on 2015/10/10.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import Foundation
import AWSIoT

typealias ServiceResponse = (String, String, NSData?, NSURLResponse?, NSError?) -> Void
typealias DataCallBack = (String, JSON, String) -> Void


class AWSApiManager: NSObject {
    
    static let sharedInstance = AWSApiManager()
    
    // Init IOT
    //
    var iotDataManager: AWSIoTDataManager!;
//    var iotData: AWSIoTData!
//    var iotManager: AWSIoTManager!;
//    var iot: AWSIoT!
    var operationInProgress: Bool = false;
    private var callbackAcceptedData = [DataCallBack]();
    var pinsCallback: DataCallBack = {_,_,_ in }
    
    
    override init() {
        super.init()
    }
    
    // GET the current status of the Pin (so the UI can be aligned with it)
    
//    func getPinStatus(pin : String, onCompletion: ServiceResponse) {
//        
//        makeHTTPGetRequest((sharedAppSettings.baseUrl + sharedAppSettings.basePin + pin), onCompletion: onCompletion)
//    }
//    
//    func getStatus(onCompletion: ServiceResponse) {
//        
//        makeHTTPGetRequest((sharedAppSettings.baseUrlPin + "getStatus"), onCompletion: onCompletion)
//    }
    
    // POST the requested status of the Pin
    
    func setPinStatus(pinNumber : Int, requestedPinSetting: String/*, onCompletion: ServiceResponse*/) {

        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [String(pinNumber):["pinStatus": requestedPinSetting=="on"]]]])
        
        iotDataManager.updateShadow(thingName, jsonString: controlJson.rawString() )
        operationInProgress = true
        
//        let path : String = sharedAppSettings.baseUrlPin + String(pinNumber) + "/" + requestedPinSetting
//        let body : [String: AnyObject] = ["" : ""]
//        
//        makeHTTPPostRequest(path, body : body, onCompletion: onCompletion)
    }
    
    func setPinTime(pinNumber : Int, requestedPinSetting: Int/*, onCompletion: ServiceResponse*/) {
        
        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [String(pinNumber):["time": requestedPinSetting]]]])
        
        iotDataManager.updateShadow(thingName, jsonString: controlJson.rawString() )
        operationInProgress = true
        
        //        let path : String = sharedAppSettings.baseUrlPin + String(pinNumber) + "/" + requestedPinSetting
        //        let body : [String: AnyObject] = ["" : ""]
        //
        //        makeHTTPPostRequest(path, body : body, onCompletion: onCompletion)
    }
    
    func getCallbackAcceptedData(callback:DataCallBack) {
        callbackAcceptedData.insert(callback, atIndex: callbackAcceptedData.count)
        //callbackAcceptedData[0] = callback;
    }
    
    func deviceShadowCallback(name:String!, operation:AWSIoTShadowOperationType, operationStatus:AWSIoTShadowOperationStatusType, clientToken:String!, payload:NSData!) -> Void {
        dispatch_async( dispatch_get_main_queue()) {
            
            let json = JSON(data: payload as NSData!)
            let stringValue = NSString(data: payload, encoding: NSUTF8StringEncoding)
            print("Received json string on callback: \(json)")
            print("Data Received: \(operation.rawValue) and \(operationStatus.rawValue)")
            switch(operationStatus) {
            case .Accepted:
                print("accepted on \(name)")
                self.thingShadowAcceptedCallback( name, json: json, payloadString: stringValue as! String)
                // if it is a get request return it to the callbacks
                switch(operation) {
                case .Get:
                    if (self.callbackAcceptedData.count > 0) {
                        print("Received accepted on get for \(thingName), calling callback")
                        //self.callbackAcceptedData[0](thingName, json, stringValue as! String)
                        for callback in self.callbackAcceptedData {
                           callback(thingName, json, stringValue as! String)
                        }
                        self.callbackAcceptedData.removeAll()
                    } else {
                        print("Received accepted on get for \(thingName), no callback")
                    }
                default: break
                }
            case .Rejected:
                print("rejected on \(name)")
                //self.thingShadowRejectedCallback( name, json: json, payloadString: stringValue as! String)
            case .Delta:
                print("delta on \(name)")
                self.thingShadowDeltaCallback( name, json: json, payloadString: stringValue as! String)
            case .Timeout:
                print("timeout on \(name)")
                
            default:
                print("unknown operation status: \(operationStatus.rawValue)")
            }
            
            self.operationInProgress = false
        }
    }
    
    func thingShadowAcceptedCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        //if (thingName == controlThingName)
        //{
//            updateControl( json["state"]["desired"]["setPoint"].int,
//                           enabled: json["state"]["desired"]["enabled"].bool );
        
        
//        }
//        else   // thingName == statusThingName
//        {
//            updateStatus( json["state"]["desired"]["intTemp"].int,
//                          exteriorTemperature: json["state"]["desired"]["extTemp"].int,
//                          state: json["state"]["desired"]["curState"].string );
//            statusThingOperationInProgress = false;
////        }
    }
    
    func thingShadowDeltaCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        pinsCallback(thingName, json, payloadString)
    }
    
    func getThingState() {
        self.iotDataManager.getShadow(thingName)
    }
    
    func subscribeToShadow(thingName: String) {
        //
        // Register the device shadows once connected.
        //
        print("Subscribing . . . . ")
        self.iotDataManager.registerWithShadow(thingName, eventCallback: self.deviceShadowCallback )
        print("Subscribed . . . . ")
        //
        // Two seconds after registering the device shadows, retrieve their current states.
        //
        // @todo make the thingName a variable that is passed through to the getThingState method
        NSTimer.scheduledTimerWithTimeInterval( 2.5, target: self, selector: #selector(self.getThingState), userInfo: nil, repeats: false )
    }
    
//    func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
//        
//        //let urlPattern = "\^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/"
//        //let regex = NSRegularExpression(pattern: urlPattern, options: nil, error: nil)
//        
//        guard let urlTarget = NSURL(string: path) else {
//            print("Error formating URL target from path: \(path)\n")
//            return
//        }
//        
//        let callType = "GET"
//        
//        let request = NSMutableURLRequest(URL: urlTarget)
//        request.timeoutInterval = sharedAppSettings.baseUrlTimeout
//        
//        let session = NSURLSession.sharedSession()
//        
//        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            
//            onCompletion(path, callType, data, response, error)
//        })
//        
//        task.resume()
//    }
//   
//    func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
//        
//        guard let urlTarget = NSURL(string: path) else {
//            print("Error formating URL target from path: \(path)\n")
//            return
//        }
//        
//        let request = NSMutableURLRequest(URL: urlTarget)
//        
//        // Set the method to POST and timeout to 10s
//        
//        let callType = "POST"
//        request.HTTPMethod = callType
//        request.timeoutInterval = sharedAppSettings.baseUrlTimeout
//        
//        // Set the POST body for the request
//        
//        let postString = "";
//        
//        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
//        
//        let session = NSURLSession.sharedSession()
//        
//        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
//            
//            onCompletion(path, callType, data, response, error)
//        })
//        
//        task.resume()
//       
//    }
}
