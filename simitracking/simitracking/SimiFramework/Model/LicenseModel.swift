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
        parameters["plaform"] = "ios"
        
        self.getAPI().getLicenseInfo(params: parameters, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
