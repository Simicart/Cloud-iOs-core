//
//  STSettingCell.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/28/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STSettingCell: SimiTableViewCell {
    
    public func addSettingWith(title: String, andView:UIView, atHeight: Int) {
        let titleLabel = SimiLabel(frame: CGRect(x: 15, y: atHeight+8, width: Int(SimiGlobalVar.screenWidth - 20 - andView.frame.size.width), height: 16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = title
        self.addSubview(titleLabel)
        
        let valueView = SimiView(frame: CGRect(x: Int(SimiGlobalVar.screenWidth - 20 - andView.frame.size.width), y: atHeight, width: Int(andView.frame.size.width), height: 40))
        valueView.addSubview(andView)
        
        self.addSubview(valueView)
    }

}
