//
//  SalesAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/1/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SalesAPI: SimiAPI {
    let kResource = "sales/"
    let kSaleInfoResourceId = "saleinfo/"
    let kRefreshInfoResourceId = "refresh/"
    
    func getSaleInfoWith(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+kSaleInfoResourceId
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
    
    func refreshSaleInfoWith(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource+kRefreshInfoResourceId
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
