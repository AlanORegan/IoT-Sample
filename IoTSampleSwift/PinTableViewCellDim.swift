///
//  pinTableViewCellDim.swift
//  IoT-Sample
//
//  Created by Alan O'Regan on 2015/12/12.
//  Copyright © 2015 Alan O'Regan. All rights reserved.
//

import UIKit

typealias CellHandlerDim = (pinNumber: Int, status : Bool) -> Void
typealias ModelHandlerDim = (setting : Int, CellHandlerDim) -> Void


class PinTableViewCellDim: UITableViewCell {
    
    // MARK: Properties
    
    var modelUpdateHandler : ModelHandlerDim?
    
    var pinCellNumber : Int?
    
    
    @IBOutlet weak var pinCellDisplayNumber: UILabel!
    @IBOutlet weak var pinCellName: UILabel!
    @IBOutlet weak var pinCellTime: UITextField!
    @IBOutlet weak var pinCellButton: UIButton!
    
    @IBAction func pinCellButtonPressed(sender: UIButton) {
        
        let requestedPinTime = Int(pinCellTime.text!)
        
        
        // Call the REST API to set the requested pin on for the requested time, then off
        
        self.modelUpdateHandler!(setting: requestedPinTime!, self.updateCell)
        
    }
    
    //Hook up the model update handler delegate
    
    func modelDelegate(modelHandler : ModelHandlerDim?) {
        self.modelUpdateHandler = modelHandler
    }
    
    //Define a reusable function for handling responses from the pin API
    
    func updateCell(pinNumber : Int , status : Bool) {
        
        if self.pinCellNumber == pinNumber {
 //           pinCellSwitch.setOn(status, animated: true)
        }
        
    }
}
