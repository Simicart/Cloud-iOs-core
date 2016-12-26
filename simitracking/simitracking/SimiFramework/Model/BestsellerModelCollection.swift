//
//  BestsellerModelCollection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/30/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class BestsellerModelCollection: SimiModelCollection {
    var privateAPI:BestsellerAPI!
    
    override func getAPI()->BestsellerAPI{
        if (privateAPI == nil) {
            privateAPI = BestsellerAPI()
        }
        return privateAPI
    }
    
    public override func getResource()->String {
        return "bestsellers"
    }
    
    public func getBestsellersWithParams(params:Dictionary<String, String>){
        currentNotificationName = "DidGetBestSellersList"
        self.preDoRequest()
        self.getAPI().getBestsellersWithParam(params: params, target: self, selector: #selector(didFinishRequest(responseObject:)))
    }
}
