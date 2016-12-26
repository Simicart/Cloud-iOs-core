//
//  StoreAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/15/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class StoreAPI: SimiAPI {
    let kResource = "stores/"
    
    func getStoresWith(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
