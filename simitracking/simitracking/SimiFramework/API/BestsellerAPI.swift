//
//  BestsellerAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/30/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class BestsellerAPI: SimiAPI {
    let kResource = "bestsellers/"
    
    func getBestsellersWithParam(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = SimiGlobalVar.baseURL+kSimiTrackingURL+kResource
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
