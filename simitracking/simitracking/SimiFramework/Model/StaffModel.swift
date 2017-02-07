//
//  StaffModel.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let DidLogin = "DidLogin"
let DidLogout = "DidLogout"

class StaffModel: SimiModel {
    
    var privateAPI:StaffAPI!
    
    override func getAPI()->StaffAPI{
        if (privateAPI == nil) {
            privateAPI = StaffAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "staff"
    }
    
    public func loginWithUserMail(userEmail:String, password:String){
        currentNotificationName = DidLogin
        self.data["email"] = userEmail as AnyObject?
        self.data["password"] = password as AnyObject?
        var tokenToSend = "nontoken_"+UIDevice.current.identifierForVendor!.uuidString
        if (STUserData.sharedInstance.deviceTokenId != "") {
            tokenToSend = STUserData.sharedInstance.deviceTokenId
        }
        var platformId = "1"
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            platformId = "2"
        }
        self.preDoRequest()
        self.getAPI().loginWithParams(params: ["email": userEmail, "password":password, "device_token":tokenToSend, "plaform_id":platformId], target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
    public func loginWithEmailAndQrSession(userEmail:String, qrsession:String){
        currentNotificationName = DidLogin
        self.data["email"] = userEmail as AnyObject?
        self.data["qr_session_id"] = qrsession as AnyObject?
        var tokenToSend = "nontoken_"+UIDevice.current.identifierForVendor!.uuidString
        if (STUserData.sharedInstance.deviceTokenId != "") {
            tokenToSend = STUserData.sharedInstance.deviceTokenId
        }
        var platformId = "1"
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
            platformId = "2"
        }
        self.preDoRequest()
        self.getAPI().loginWithKeySession(params: ["qr_session_id": qrsession, "new_token_id":tokenToSend, "plaform_id":platformId], target: self, selector: #selector(didFinishRequest(responseObject:)))
    }

    func logoutWithDeviceToken(_ deviceToken:String){
        currentNotificationName = DidLogout
        preDoRequest()
        getAPI().logoutWithParams(["device_token":STUserData.sharedInstance.deviceTokenId], target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
}
