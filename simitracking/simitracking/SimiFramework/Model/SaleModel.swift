//
//  SaleModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/1/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SaleModel: SimiModel {
    var privateAPI:SalesAPI!
    
    override func getAPI()->SalesAPI{
        if (privateAPI == nil) {
            privateAPI = SalesAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "sale"
    }
    
    public func getSaleInfoWith(params:Dictionary<String, String>){
        currentNotificationName = "DidGetSaleInfo"
        self.preDoRequest()
        self.getAPI().getSaleInfoWith(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
    public func refreshSaleInfo(params:Dictionary<String, String>){
        currentNotificationName = "DidGetSaleInfo"
        self.preDoRequest()
        self.getAPI().refreshSaleInfoWith(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
