//
//  StaffAPI.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit


class StaffAPI: SimiAPI {
    
    let kResource = "staffs/"
    let kLoginResourceId = "login/"
    let kLoginWithKeySessionResourceId = "loginWithKeySession/"
    
    
    
    func loginWithParams(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+kLoginResourceId
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func loginWithKeySession(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+kLoginWithKeySessionResourceId
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
