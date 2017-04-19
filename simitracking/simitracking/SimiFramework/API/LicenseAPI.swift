//
//  LicenseAPI.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 12/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class LicenseAPI: SimiAPI {
    func getLicenseInfo(params:Dictionary<String, String>, target:NSObject, selector:Selector) {
        let url:String = kSimiLicenseURL
        //self request
        self.requestWithURL(url: url, params: params, target: target, selector: selector, header:[String: String]())
    }
}
