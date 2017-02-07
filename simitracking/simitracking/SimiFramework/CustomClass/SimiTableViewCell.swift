//
//  SimiTableViewCell.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/21/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiTableViewCell: UITableViewCell, UITextFieldDelegate {

    public var isEditable:Bool = false{
        didSet{
            for view in self.contentView.subviews{
                if view.isKind(of: SimiTextField.self){
                    let textField: SimiTextField = view as! SimiTextField
                    if(isEditable){
                        textField.layer.borderColor = UIColor.lightGray.cgColor
                        textField.layer.borderWidth = 0.5
                        textField.isEditable = true
                    }else{
                        textField.layer.borderWidth = 0
                        textField.isEditable = false
                    }
                }
            }
        }
    }
    
    func addValueLabel(withTitle: String, andValue: String, atHeight: Int) {
        addValueLabel(withTitle: withTitle, andValue: andValue, atHeight: atHeight, isCopiable: false)
    }
    
    func addValueLabel(withTitle: String, andValue: String, atHeight: Int, textColor:UIColor) {
        addValueLabel(withTitle: withTitle, andValue: andValue, atHeight: atHeight, isCopiable: false, textColor:textColor)
    }
    
    func addValueLabel(withTitle: String, andValue: String, atHeight: Int, isCopiable:Bool) {
        addValueLabel(withTitle: withTitle, andValue: andValue, atHeight: atHeight, isCopiable: isCopiable, textColor: UIColor.darkGray)
    }
    
    func addValueLabel(withTitle: String, andValue: String, atHeight: Int, isCopiable:Bool, textColor:UIColor) {
        let titleLabel = SimiLabel(frame: CGRect(x: 15, y: atHeight, width: 140, height: 16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = THEME_BOLD_FONT
        titleLabel.text = withTitle
        self.contentView.addSubview(titleLabel)
        
        let valueLabel = SimiLabel(frame: CGRect(x: 160, y: atHeight, width: Int(SimiGlobalVar.screenWidth - 170), height: 16))
        valueLabel.textColor = textColor
        valueLabel.isCopiable = isCopiable
        valueLabel.font = THEME_FONT
        valueLabel.text = andValue
        self.contentView.addSubview(valueLabel)
    }
    
    func addEditableTextField(textField:SimiTextField!, withTitle: String, andValue:String, atHeight: Int){
        let titleLabel = SimiLabel(frame: CGRect(x:15, y: atHeight, width:140, height:16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = THEME_BOLD_FONT
        titleLabel.text = withTitle
        self.contentView.addSubview(titleLabel)
        
        textField.frame = CGRect(x:155, y:atHeight, width:Int(SimiGlobalVar.screenWidth - 165),height:20)
        textField.delegate = self
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        textField.textColor = UIColor.darkGray
        textField.font = THEME_FONT
        textField.text = andValue
        self.contentView.addSubview(textField)
    }
    
    func addURLLabel(withTitle:String, value:String, atHeight:Int, urlType:LabelURLType){
        let titleLabel = SimiLabel(frame: CGRect(x: 15, y: atHeight, width: 140, height: 16))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = THEME_BOLD_FONT
        titleLabel.text = withTitle
        self.contentView.addSubview(titleLabel)
        
        let valueLabel = SimiLabel(frame: CGRect(x: 160, y: atHeight, width: Int(SimiGlobalVar.screenWidth - 170), height: 16))
        valueLabel.isURL = true
        valueLabel.urlType = urlType
        valueLabel.font = THEME_FONT
        valueLabel.text = value
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: value, attributes: underlineAttribute)
        valueLabel.attributedText = underlineAttributedString
        self.contentView.addSubview(valueLabel)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if isEditable{
            return true
        }else{
            return false
        }
    }
}
