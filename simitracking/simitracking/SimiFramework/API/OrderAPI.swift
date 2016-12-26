//
//  OrderAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/15/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit



class OrderAPI: SimiAPI {
    let kResource = "orders/"
    
    func getOrderListWithParam(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func getOrderDetailWithId(id: String,params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+id
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func updateOrderDetailWithId(id: String,params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+id
        //self request
        self.putRequestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
