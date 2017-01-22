//
//  ForecastSaleAPI.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/18/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import Foundation
class ForecastSaleAPI: SimiAPI {
    let kForecastSale = "salesforecasts/day"
    
    func getForecastSaleWithParams(params:Dictionary<String, String>, target:NSObject, selector:Selector){
        let url: String = SimiGlobalVar.baseURL + kSimiTrackingURL+kForecastSale
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header: [:])
    }
}
