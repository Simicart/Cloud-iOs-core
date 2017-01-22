//
//  SimiTextField.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/9/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import UIKit

class SimiTextField: UITextField {
    public var isEditable: Bool = true{
        didSet{
            if isEditable{
                self.isEnabled = true
            }else{
                self.isEnabled = false
            }
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
