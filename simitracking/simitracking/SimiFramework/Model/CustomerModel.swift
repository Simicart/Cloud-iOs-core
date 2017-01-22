//
//  CustomerModel.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/20/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let DidGetCustomerDetail = "DidGetCustomerDetail"
let DidEditCustomerDetail = "DidEditCustomerDetail"

class CustomerModel: SimiModel {
    
    var privateAPI:CustomerAPI!
    
    override func getAPI()->CustomerAPI{
        if (privateAPI == nil) {
            privateAPI = CustomerAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "customer"
    }
    
    public func getCustomerDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = "DidGetCustomerDetail"
        self.preDoRequest()
        self.getAPI().getCustomerDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
    public func editCustomerDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = DidEditCustomerDetail
        self.preDoRequest()
        self.getAPI().editCustomerDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    
}
