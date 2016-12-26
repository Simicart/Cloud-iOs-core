//
//  ProductModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/25/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class ProductModelCollection: SimiModelCollection {
    var privateAPI:ProductAPI!
    
    override func getAPI()->ProductAPI{
        if (privateAPI == nil) {
            privateAPI = ProductAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "products"
    }
    
    public func getProductListWithParam(params:Dictionary<String, String>){
        currentNotificationName = "DidGetProductList"
        self.preDoRequest()
        self.getAPI().getProductListWithParam(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
