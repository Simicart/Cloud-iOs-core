//
//  AbandonedCartModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/23/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class AbandonedCartModel: SimiModel {
    var privateAPI:AbandonedCartAPI!
    
    override func getAPI()->AbandonedCartAPI{
        if (privateAPI == nil) {
            privateAPI = AbandonedCartAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "abandonedcart"
    }
    
    public func getAbandonedCartDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = "DidGetAbandonedCartDetail"
        self.preDoRequest()
        self.getAPI().getAbandonedCartDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
