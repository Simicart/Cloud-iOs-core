//
//  STUserData.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/29/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STUserData: NSObject {
    var userEmail = ""
    var userPassword = ""
    var userURL = ""
    var qrSessionId = ""
    
    var itemPerPage = 40
    var showDashboardSales = true
    var showDashboardBestsellers = true
    var showDashboardLatestOrders = true
    var showDashboardLatestCustomers = true
    
    public func saveToLocal() {
        SimiDataLocal.setLocalData(data: userEmail, forKey: (userEmail + "_email"))
        SimiDataLocal.setLocalData(data: userPassword, forKey: (userEmail + "_password"))
        SimiDataLocal.setLocalData(data: userURL, forKey: (userEmail + "_url"))
        SimiDataLocal.setLocalData(data: qrSessionId, forKey: (userEmail + "_qrSessionId"))
        
        SimiDataLocal.setLocalData(data: String(itemPerPage), forKey: (userEmail + "_itemPerPage"))
        SimiDataLocal.setLocalData(data: showDashboardSales.description, forKey: (userEmail + "_showDashboardSales"))
        SimiDataLocal.setLocalData(data: showDashboardBestsellers.description, forKey: (userEmail + "_showDashboardBestsellers"))
        SimiDataLocal.setLocalData(data: showDashboardLatestOrders.description, forKey: (userEmail + "_showDashboardLatestOrders"))
        SimiDataLocal.setLocalData(data: showDashboardLatestCustomers.description, forKey: (userEmail + "_showDashboardLatestCustomers"))
        updateToGlobalVars()
    }
    
    public func loadFromLocal() {
        userPassword = SimiDataLocal.getLocalData(forKey: userEmail + "_password") as! String
        userURL = SimiDataLocal.getLocalData(forKey: userEmail + "_url") as! String
        qrSessionId = SimiDataLocal.getLocalData(forKey: userEmail + "_qrSessionId") as! String
        
        if (SimiDataLocal.getLocalData(forKey: userEmail + "_itemPerPage") as! String) != "" {
            itemPerPage = Int(SimiDataLocal.getLocalData(forKey: userEmail + "_itemPerPage") as! String)!
        }
        if(SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardSales") as! String) == "false"{
            showDashboardSales = false
        }
        if(SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardBestsellers") as! String) == "false"{
            showDashboardBestsellers = false
        }
        if(SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestOrders") as! String) == "false"{
            showDashboardLatestOrders = false
        }
        if(SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestCustomers") as! String) == "false"{
            showDashboardLatestCustomers = false
        }
        updateToGlobalVars()
    }
    
    func updateToGlobalVars() {
        SimiGlobalVar.itemsPerPage = itemPerPage
    }
}
