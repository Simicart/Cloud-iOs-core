//
//  AuthorizeAPI.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 4/18/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import Foundation

class AuthorizeAPI : SimiAPI{
    func getAuthorizeInfo(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = kAuthorizeURL
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
