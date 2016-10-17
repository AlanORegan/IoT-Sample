//
//  pinTableViewCellSw.swift
//  IoT-Sample
//
//  Created by Alan O'Regan on 2015/12/12.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import UIKit

typealias CellHandlerSw = (pinNumber: Int, status : Bool) -> Void
typealias ModelHandlerSw = (setting : String, CellHandlerSw) -> Void


class PinTableViewCellSw: UITableViewCell {
    
    // MARK: Properties
    
    var modelUpdateHandler : ModelHandlerSw?
    
    var pinCellNumber : Int?
    
    
    @IBOutlet weak var pinCellDisplayNumber: UILabel!
    @IBOutlet weak var pinCellName: UILabel!
    @IBOutlet weak var pinCellSwitch: UISwitch!
    
    
    @IBAction func pinCellSwitchChanged(sender: UISwitch) {
    
        var requestedpinSetting = ""
        
        // Interpret whether the UI is requesting the pin to be set on or off
        
        switch sender.on {
        case true:
            requestedpinSetting = "on"
        case false:
            requestedpinSetting = "off"
        }
        
        // Call the REST API to set the requested pin value (on or off)
        
        self.modelUpdateHandler!(setting: requestedpinSetting, self.updateCell)
        
    }
    
    //Hook up the model update handler delegate
    
    func modelDelegate(modelHandler : ModelHandlerSw?) {
        self.modelUpdateHandler = modelHandler
    }
    
    //Define a reusable function for handling responses from the pin API
    
    func updateCell(pinNumber : Int , status : Bool) {
        
        if self.pinCellNumber == pinNumber {
            pinCellSwitch.setOn(status, animated: true)
        }
        
    }
}
