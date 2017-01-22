//
//  CustomerAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/19/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class CustomerAPI: SimiAPI {
    let kResource = "customers/"
    
    func getCustomerListWithParam(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func getCustomerDetailWithId(id: String,params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+id
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func editCustomerDetailWithId(id:String,params:Dictionary<String, String>, target:NSObject, selector:Selector){
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+id
        self.putRequestWithURL(url: url, params: params, target: target, selector: selector, header: [:])
    }
}
