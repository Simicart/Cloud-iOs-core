//
//  AddressModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/21/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class AddressModelCollection: SimiModelCollection {
    var privateAPI:AddressAPI!
    
    override func getAPI()->AddressAPI{
        if (privateAPI == nil) {
            privateAPI = AddressAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "addresses"
    }
    
    public func getAddressListWithParams(params:Dictionary<String, String>){
        currentNotificationName = "DidGetAddressList"
        self.preDoRequest()
        self.getAPI().getAddressListWithParams(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }

}
