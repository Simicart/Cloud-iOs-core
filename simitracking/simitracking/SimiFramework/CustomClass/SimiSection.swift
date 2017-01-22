//
//  SimiSection.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/11/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiSection: NSObject {
    var identifier = ""
    var height:CGFloat = 0
    var childRows:Array<SimiRow> = []
    var data:Dictionary<String,Any> = [:]
    
    var rowCount: Int{
        get{
            return childRows.count
        }
    }
    
    init(identifier:String){
        super.init()
        self.identifier = identifier;
    }
    
    func addRowWithIdentifier(identifier:String, height:CGFloat){
        let row = SimiRow.init(withIdentifier: identifier, andHeight: height)
        childRows.append(row)
    }
    
    func rowAtIndex(index:Int) -> SimiRow{
        return childRows[index]
    }
    
    override init() {
        super.init()
    }
}
