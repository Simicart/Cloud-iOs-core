//
//  SimiModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/14/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiModelCollection: NSObject {
    
    static var simiAPI:SimiAPI!
    public var currentNotificationName:String = "DidFinishRequest"
    public var data:Array<Dictionary<String, Any>> = []
    
    public var error:Array<Dictionary<String, Any>>!
    public var isSucess:Bool!
    
    public var allIds:Array<String>?
    public var total:Int?
    public var pageSize:Int?
    public var from:Int?
    public var responseObject:Dictionary<String, AnyObject>?
    
    
    public func getAPI()->SimiAPI{
        return SimiAPI()
    }
    
    public func deleteData() {
        data.removeAll()
    }
    
    public func getResource()->String {
        return ""
    }
    
    public func setData(data: Array<Dictionary<String, Any>>) {
        if (self.data.count>=1) {
            self.data.removeAll()
        }
        for item in data {
            self.data.append(item)
        }
    }
    
    public func addData(data: Array<Dictionary<String, Any>>) {
        for item in data {
            self.data.append(item)
        }
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
            allIds = responseObject["all_ids"] as! Array<String>?
            total = responseObject["total"] as? Int
            pageSize = responseObject["page_size"] as? Int
            from = responseObject["from"] as? Int
            self.responseObject = responseObject
        }
        if self.isSucess == true {
            setData(data: responseObject[getResource()] as! Array<Dictionary<String, Any>>)
        }
        self .pushNotifications(responseObject: responseObject)
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
