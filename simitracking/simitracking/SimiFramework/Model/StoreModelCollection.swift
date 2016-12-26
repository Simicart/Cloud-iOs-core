//
//  StoreModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/15/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class StoreModelCollection: SimiModelCollection {
    var privateAPI:StoreAPI!
    
    override func getAPI()->StoreAPI{
        if (privateAPI == nil) {
            privateAPI = StoreAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "stores"
    }
    
    public func getStores(){
        currentNotificationName = "DidGetStores"
        
        self.preDoRequest()
        self.getAPI().getStoresWith(params: [:], target: self, selector: #selector(didFinishRequest(responseObject:)))
    }

}
