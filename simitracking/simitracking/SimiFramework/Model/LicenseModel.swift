//
//  LicenseModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class LicenseModel: SimiModel {
    var privateAPI:LicenseAPI!
    var qrCodeEnabled: Bool! = true
    
    override func getAPI()->LicenseAPI{
        if (privateAPI == nil) {
            privateAPI = LicenseAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "license"
    }
    
    public func getLicenseInfo(params:Dictionary<String, String>){
        currentNotificationName = "DidGetLicenseInfo"
        self.preDoRequest()
        
        var parameters = params
        parameters["url"] = SimiGlobalVar.baseURL
        parameters["version"] = "tracking"
        parameters["platform"] = "ios"
        
        self.getAPI().getLicenseInfo(params: parameters, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
    override func didFinishRequest(responseObject: Dictionary<String, AnyObject>) {
        self.error = nil
        if responseObject["errors"] != nil
        {
            self.error = responseObject["errors"] as! Array<Dictionary<String, Any>>
            self.isSucess = false
        }
        else {
            self.isSucess = true
        }
        if self.isSucess == true {
            self.data = responseObject[getResource()] as! Dictionary<String, Any>!
            self.qrCodeEnabled = responseObject["qr_code"]?.boolValue
        }
        pushNotifications(responseObject: responseObject)
    }
    
}
