//
//  AbandonedCartAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/23/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class AbandonedCartAPI: SimiAPI {
    let kResource = "abandonedcarts/"
    
    func getAbandonedCartListWithParam(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func getAbandonedCartDetailWithId(id: String,params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+id
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
