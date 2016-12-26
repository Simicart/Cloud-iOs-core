//
//  CustomerModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/19/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class CustomerModelCollection: SimiModelCollection {
    var privateAPI:CustomerAPI!
    
    override func getAPI()->CustomerAPI{
        if (privateAPI == nil) {
            privateAPI = CustomerAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "customers"
    }
    
    public func getCustomerListWithParam(params:Dictionary<String, String>){
        currentNotificationName = "DidGetCustomerList"
        self.preDoRequest()
        self.getAPI().getCustomerListWithParam(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
