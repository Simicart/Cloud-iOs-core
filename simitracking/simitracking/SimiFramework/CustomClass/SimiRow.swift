//
//  SimiRow.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/11/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiRow: NSObject {
    var data:Dictionary<String,Any> = [:]
    var height:CGFloat = 0
    var identifier = ""
    
    convenience init(withIdentifier: String) {
        self.init()
        self.identifier = withIdentifier
    }
    
    convenience init(withIdentifier: String, andHeight: CGFloat) {
        self.init()
        self.identifier = withIdentifier
        self.height = andHeight
    }
}
