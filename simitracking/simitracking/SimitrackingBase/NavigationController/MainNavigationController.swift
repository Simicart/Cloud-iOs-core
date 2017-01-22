//
//  MainNavigationController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/11/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

protocol MainNavigationControllerDelegate {
    func onMenuButtonTapped()
    func dismissDrawerController()
}

class MainNavigationController: SimiNavigationController {

    public var menuButton :UIBarButtonItem!
    var rootDelegate: MainNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor =  THEME_COLOR
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        UIToolbar.appearance().tintColor = UIColor.gray
        createLeftMenuButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func menuTapped() {
        rootDelegate?.onMenuButtonTapped()
    }
    
    public func dismissDrawerController() {
        rootDelegate?.dismissDrawerController()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    public func createLeftMenuButton() {
        if (menuButton == nil) {
            let button: SimiButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 65, height: 65))
            button.contentEdgeInsets = UIEdgeInsetsMake(15, 0, 15, 30)
            button.setImage(UIImage(named: "menu_icon.png"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
            menuButton = UIBarButtonItem(customView: button)
        }
    }

}
