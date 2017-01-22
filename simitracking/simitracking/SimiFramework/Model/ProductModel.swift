//
//  ProductModel.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let DidGetProductDetail = "DidGetProductDetail"
let DidEditProductDetail = "DidEditProductDetail"

class ProductModel: SimiModel {
    var privateAPI:ProductAPI!
    
    override func getAPI()->ProductAPI{
        if (privateAPI == nil) {
            privateAPI = ProductAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "product"
    }
    
    public func getProductDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = DidGetProductDetail
        self.preDoRequest()
        self.getAPI().getProductDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
    public func editProductDetailWithId(id:String, params:Dictionary<String, String>){
        currentNotificationName = DidEditProductDetail
        self.preDoRequest()
        self.getAPI().editProductDetailWithId(id: id, params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
