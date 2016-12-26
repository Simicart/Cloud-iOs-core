//
//  OrderModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/14/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class OrderModelCollection: SimiModelCollection {
    var privateAPI:OrderAPI!
    
    override func getAPI()->OrderAPI{
        if (privateAPI == nil) {
            privateAPI = OrderAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "orders"
    }
    
    public func getOrderListWithParam(params:Dictionary<String, String>){
        currentNotificationName = "DidGetOrderList"
        self.preDoRequest()
        self.getAPI().getOrderListWithParam(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
