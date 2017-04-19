//
//  SimiAPI.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let kSimiConnectorURL:String = "simiconnector/rest/v2/"
let kSimiTrackingURL:String = "simitracking/rest/v2/"
let kSimiLicenseURL:String = "https://www.simicart.com/usermanagement/api/authorize"
let kAuthorizeURL:String = "https://www.simicart.com/usermanagement/api/authorize"

class SimiAPI: NSObject {
    
    var target:NSObject!
    var selector:Selector!
    var networkManager:SimiNetworkManager!
    
    func requestWithURL(url:String, params:Dictionary<String, String>, target:NSObject, selector:Selector, header:Dictionary<String, String>) {
        self.target = target
        self.selector = selector;
        self.getNetWorkManager().requestWithMethod(method: SIMI_GET, urlPath: url, parameters:params, target: target, selector: selector, header: header)
    }
    
    func putRequestWithURL(url:String, params:Dictionary<String, String>, target:NSObject, selector:Selector, header:Dictionary<String, String>) {
        self.target = target
        self.selector = selector;
        self.getNetWorkManager().requestWithMethod(method: SIMI_PUT, urlPath: url, parameters:params, target: target, selector: selector, header: header)
    }
    
    func getNetWorkManager()->SimiNetworkManager {
        if (networkManager == nil){
            networkManager = SimiNetworkManager()
        }
        return networkManager
    }
    
}
