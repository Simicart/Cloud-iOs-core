//
//  OrderModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/17/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class OrderModel: SimiModel {
    var privateAPI:OrderAPI!
    
    override func getAPI()->OrderAPI{
        if (privateAPI == nil) {
            privateAPI = OrderAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "order"
    }
    
    public func getOrderDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = "DidGetOrderDetail"
        self.preDoRequest()
        self.getAPI().getOrderDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
    
    public func updateOrderDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = "DidUpdateOrder"
        self.preDoRequest()
        self.getAPI().updateOrderDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
