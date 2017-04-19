//
//  LicenseModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit
let DidGetAuthorizeInfo = "DidGetAuthorizeInfo"
class AuthorizeModel: SimiModel {
    var privateAPI:AuthorizeAPI!
    var qrCodeEnabled: Bool! = true
    
    override func getAPI()->AuthorizeAPI{
        if (privateAPI == nil) {
            privateAPI = AuthorizeAPI()
        }
        return privateAPI
    }
    
    public func getAuthorizeInfo(params:Dictionary<String, String>){
        currentNotificationName = DidGetAuthorizeInfo
        self.preDoRequest()
        self.getAPI().getAuthorizeInfo(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
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
            self.qrCodeEnabled = responseObject["qr_code"]?.boolValue
        }
        pushNotifications(responseObject: responseObject)
    }
    
}
