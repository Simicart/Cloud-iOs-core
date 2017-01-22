//
//  ForecastSaleModel.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/18/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import Foundation
let DidGetForecastSale = "DidGetForecastSale"
class ForecastSaleModel: SimiModel{
    var privateAPI:ForecastSaleAPI!
    
    override func getAPI()->ForecastSaleAPI{
        if (privateAPI == nil) {
            privateAPI = ForecastSaleAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "salesforecast"
    }
    
    public func getForecastSaleWith(params: Dictionary<String, String>){
        currentNotificationName = DidGetSaleInfo
        self.preDoRequest()
        self.getAPI().getForecastSaleWithParams(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
