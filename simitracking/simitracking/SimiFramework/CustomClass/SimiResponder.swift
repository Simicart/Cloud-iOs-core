//
//  SimiResponder.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/8/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiResponder: NSObject {
    var status:String = ""
    var message:Array<NSObject>!
    var other:Array<NSObject>!
    var error:Error!
    
    func responseMessage()->String{
        var mess:String = ""
        if (error == nil) {
            if (message != nil && message.count >= 1) {
                mess = message[0] as! String
            }
        }
        return mess
    }
            
}
