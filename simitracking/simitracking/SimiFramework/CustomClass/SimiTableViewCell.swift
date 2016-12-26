//
//  SimiTableViewCell.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/21/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiTableViewCell: UITableViewCell, UITextFieldDelegate {

    func addValueLabel(withTitle: String, andValue: String, atHeight: Int) {
        let titleLabel = SimiLabel(frame: CGRect(x: 15, y: atHeight, width: 140, height: 16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.text = withTitle
        self.addSubview(titleLabel)
        
        let valueLabel = SimiLabel(frame: CGRect(x: 160, y: atHeight, width: Int(SimiGlobalVar.screenWidth - 170), height: 16))
        valueLabel.textColor = UIColor.darkGray
        valueLabel.font = UIFont.systemFont(ofSize: 13)
        valueLabel.text = andValue
        self.addSubview(valueLabel)
    }
    
    func addCopiableValueLabel(withTitle: String, andValue: String, atHeight: Int) {
        let titleLabel = SimiLabel(frame: CGRect(x: 15, y: atHeight, width: 140, height: 16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.text = withTitle
        self.addSubview(titleLabel)
        
        let valueLabel = UITextField(frame: CGRect(x: 160, y: atHeight, width: Int(SimiGlobalVar.screenWidth - 170), height: 16))
        valueLabel.textColor = UIColor.blue
        
        valueLabel.font = UIFont.systemFont(ofSize: 13)
        valueLabel.text = andValue
        self.addSubview(valueLabel)
    }
    
    //MARK: - TextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}
