//
//  SimiLabel.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/6/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class SimiLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
//    override public var text: String?{
//        didSet{
//            text = STLocalizedString(inputString: text!)
//        }
//    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    public var isCopiable: Bool?{
        didSet{
            if(isCopiable)!{
                self.isUserInteractionEnabled = true
                self.isEnabled = true
                self.addGestureRecognizer(UITapGestureRecognizer(target:self,action:#selector(didTapOn)))
                self.textColor = UIColor.blue
            }
        }
    }
    
    func copyContent(){
        let pb: UIPasteboard = UIPasteboard.general
        pb.string = self.text
    }
    
    func didTapOn(){
        self.becomeFirstResponder()
        let menuController: UIMenuController = UIMenuController.shared
        let copyMenuItem:UIMenuItem = UIMenuItem.init(title: STLocalizedString(inputString: "Copy"), action: #selector(copyContent))
        menuController.menuItems = [copyMenuItem]
        menuController.setTargetRect(bounds, in: self)
        menuController.setMenuVisible(true, animated: true)
    }
}
