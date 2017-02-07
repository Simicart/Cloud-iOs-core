//
//  StoreviewFilterViewController.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/15/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class StoreviewFilterViewController: SimiViewController, UIActionSheetDelegate {

    
    var storeViewButton:SimiButton!
    var storeModelCollection:StoreModelCollection!
    var storeviewNameLabel:SimiLabel!
    
    var storeSelectActionSheet:UIActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (SimiGlobalVar.storeList == nil) {
            getStores()
        } else {
            updateStoreViewButton()
        }
    }
    
    
    public func getStores(){
        if (storeModelCollection == nil) {
            storeModelCollection = StoreModelCollection()
        }
        storeModelCollection.getStores()
        NotificationCenter.default.addObserver(self, selector: #selector(didGetStores(notification:)), name: NSNotification.Name(rawValue: "DidGetStores"), object: nil)
    }
    
    // Get Stores handler
    func didGetStores(notification: NSNotification) {
        self.hideLoadingView()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DidGetStores"), object: nil)
        if storeModelCollection.isSucess != false {
            if (SimiGlobalVar.storeList == nil) {
                SimiGlobalVar.storeList = []
                for store in storeModelCollection.data {
                    //let storeName = store["name"] as! String
                    let storeviewList = store["storeviews"] as! Dictionary<String, Any>
                    let storeviewArray = storeviewList["storeviews"] as! Array<Dictionary<String, Any>>
                    for var storeview in storeviewArray {
                        let newDictionary = ["name":storeview["name"],"code":storeview["code"],"store_id":storeview["store_id"],"action_sheet_index":-1]
                        SimiGlobalVar.storeList.append(newDictionary)
                    }
                }
                updateStoreViewButton()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func updateStoreViewButton() {
        if (storeViewButton == nil) {
            storeViewButton = SimiButton(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
            
            let triangleView = SimiImageView(frame: CGRect(x: 62, y: 13, width: 8, height: 8))
            triangleView.image = UIImage(named: "triangle_icon")
            storeViewButton.addSubview(triangleView)
            
            storeviewNameLabel = SimiLabel(frame: CGRect(x: -10, y: 10, width: 70, height: 13))
            storeviewNameLabel.textColor = UIColor.white
            storeviewNameLabel.font = UIFont.boldSystemFont(ofSize: 13)
            storeviewNameLabel.textAlignment = NSTextAlignment.right
            storeViewButton.addSubview(storeviewNameLabel)
            
            storeViewButton.addTarget(self, action: #selector(showStoreOptions), for: UIControlEvents.touchUpInside)
        }
        
        storeviewNameLabel.text = STLocalizedString(inputString: "All Stores")
        for store in SimiGlobalVar.storeList {
            if store["store_id"] as! String == SimiGlobalVar.selectedStoreId {
                storeviewNameLabel.text = store["code"] as? String
            }
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: storeViewButton)
    }
    
    public func showStoreOptions() {
        storeSelectActionSheet = UIActionSheet(title: STLocalizedString(inputString: "Switch Store view"), delegate: self, cancelButtonTitle: STLocalizedString(inputString: "Cancel"), destructiveButtonTitle: nil)
        
        storeSelectActionSheet.addButton(withTitle: STLocalizedString(inputString: "All Stores"))
        for (index,store) in SimiGlobalVar.storeList.enumerated() {
            let storeViewOptionTitle = (store["name"] as! String) + " (" + (store["code"] as! String) + ")"
            let actionSheetIndex = storeSelectActionSheet.addButton(withTitle: storeViewOptionTitle)
            SimiGlobalVar.storeList[index]["action_sheet_index"] = actionSheetIndex
        }
        storeSelectActionSheet.show(in: self.view)

    }
    
    // MARK: - Action Sheet delegate
    func actionSheet(_ actionSheet: UIActionSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if (storeSelectActionSheet != nil) && (actionSheet == storeSelectActionSheet) {
            if buttonIndex == 0 {
                return
            }
            SimiGlobalVar.selectedStoreId = ""
            for store in SimiGlobalVar.storeList {
                if store["action_sheet_index"] as! Int == buttonIndex {
                    SimiGlobalVar.selectedStoreId = store["store_id"] as! String
                    trackEvent("change_store", params: ["store_id":SimiGlobalVar.selectedStoreId])
                }
            }
            switchStore()
            updateStoreViewButton()
        }
    }
    
    // MARK: - Switch Store
    public func switchStore() {
        
    }

}
