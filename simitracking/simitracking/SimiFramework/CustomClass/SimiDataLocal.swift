//
//  SimiDataLocal.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/28/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiDataLocal: NSObject {
    public static func setLocalData(data: Any, forKey: String) {
        let defaults = UserDefaults.standard
        defaults.set(data, forKey: forKey)
        defaults.synchronize()
    }
    
    public static func getLocalData(forKey: String)->Any {
        let value = UserDefaults.standard.object(forKey: forKey)
        if (value == nil) || (value is NSNull)
        {
            return ""
        }
        else {
            return value ?? ""
        }
    }
}
