//
//  AbandonedCartModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/23/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class AbandonedCartModelCollection: SimiModelCollection {
    var privateAPI:AbandonedCartAPI!
    
    override func getAPI()->AbandonedCartAPI{
        if (privateAPI == nil) {
            privateAPI = AbandonedCartAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "abandonedcarts"
    }
    
    public func getAbandonedCartWithParams(params:Dictionary<String, String>){
        currentNotificationName = "DidGetAbandonedCartList"
        self.preDoRequest()
        self.getAPI().getAbandonedCartListWithParam(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
