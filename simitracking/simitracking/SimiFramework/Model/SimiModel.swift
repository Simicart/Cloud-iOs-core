//
//  SimiModel.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import Alamofire
import UIKit

class SimiModel: NSObject {
    
    static var simiAPI:SimiAPI!
    public var currentNotificationName:String = "DidFinishRequest"
    public var data:Dictionary<String, Any> = [:]
    
    public var error:Array<Dictionary<String, Any>>!
    public var isSucess = false
    
    
    public func getAPI()->SimiAPI{
        return SimiAPI()
    }
    
    public func deleteData() {
        data.removeAll()
    }
    
    public func setData(data: Dictionary<String, String>) {
        if (self.data.count>=1) {
            self.data.removeAll()
        }
        for (key, value) in data {
            self.data[key] = value
        }
    }
    
    public func addData(data: Dictionary<String, String>) {
        for (key, value) in data {
            self.data[key] = value
        }
    }
    
    public func getResource()->String {
        return ""
    }
    
    
    func preDoRequest() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: currentNotificationName+"Before"), object: self)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLoaderStart"), object: currentNotificationName)
        if (currentNotificationName != "DidFinishRequest") {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DidFinishRequest-Before"), object: self)
        }
    }
    
    public func didFinishRequest(responseObject:Dictionary<String, AnyObject>){
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
        }
        pushNotifications(responseObject: responseObject)
    }
    
    public func pushNotifications(responseObject:Dictionary<String, AnyObject>) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: currentNotificationName+"After"), object: self)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TimeLoaderStop"), object: currentNotificationName)
        NotificationCenter.default.post(name: Notification.Name(rawValue: currentNotificationName), object: self, userInfo: responseObject)
        
        if (currentNotificationName != "DidFinishRequest") {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DidFinishRequest-After"), object: self)
        }
    }
}
