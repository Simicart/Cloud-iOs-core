//
//  STUserData.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/29/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let currencyLeft: String = "Left"
let currencyRight: String = "Right"
let currencyLeftSpace: String = "Left Space"
let currencyRightSpace: String = "Right Space"

class STUserData: NSObject {
    static let sharedInstance = STUserData()
    private var privateUserEmail = ""
    var deviceTokenId: String{
        set(newDeviceTokenId){
            SimiDataLocal.setLocalData(data: newDeviceTokenId, forKey: userEmail + "_deviceTokenId")
        }
        get{
            return SimiDataLocal.getLocalData(forKey: userEmail + "_deviceTokenId") as! String
        }
    }
    var userEmail: String{
        set(newUserEmail){
            SimiDataLocal.setLocalData(data: newUserEmail, forKey: (userEmail + "_email"))
            privateUserEmail = newUserEmail
        }
        get{
            return SimiDataLocal.getLocalData(forKey: privateUserEmail + "_email") as! String
        }
    }
    var userPassword:String{
        set(newPassword){
            SimiDataLocal.setLocalData(data: newPassword, forKey: (userEmail + "_password"))
        }
        get{
            return SimiDataLocal.getLocalData(forKey: userEmail + "_password") as! String
        }
    }
    var userURL:String{
        set(newURL){
            SimiDataLocal.setLocalData(data: newURL, forKey: (userEmail + "_url"))
        }
        get{
            return SimiDataLocal.getLocalData(forKey: userEmail + "_url") as! String
        }
    }
    var qrSessionId:String{
        set(newQrSession){
            SimiDataLocal.setLocalData(data: newQrSession, forKey: (userEmail + "_qrSessionId"))
        }
        get{
            return SimiDataLocal.getLocalData(forKey: userEmail + "_qrSessionId") as! String
        }
    }
    
    var itemPerPage: Int{
        set(newItemPerPage){
            SimiDataLocal.setLocalData(data: String(newItemPerPage), forKey: (userEmail + "_itemPerPage"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_itemPerPage") as! String == ""{
                return 40
            }else{
                return Int(SimiDataLocal.getLocalData(forKey: userEmail + "_itemPerPage") as! String)!
            }
        }
    }
    var showDashboardSales:Bool{
        set(newShowDashboardSales){
            SimiDataLocal.setLocalData(data: newShowDashboardSales, forKey: (userEmail + "_showDashboardSales"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardSales") is Bool{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardSales") as! Bool
            }else{
                return true
            }
        }
    }
    var showDashboardBestsellers:Bool{
        set(newShowDashboardBestsellers){
            SimiDataLocal.setLocalData(data: newShowDashboardBestsellers, forKey: (userEmail + "_showDashboardBestsellers"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardBestsellers") is Bool{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardBestsellers") as! Bool
            }else{
                return true
            }
        }
    }
    var showDashboardLatestOrders:Bool{
        set(newShowDashboardLatestOrders){
            SimiDataLocal.setLocalData(data: newShowDashboardLatestOrders, forKey: (userEmail + "_showDashboardLatestOrders"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestOrders") is Bool{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestOrders") as! Bool
            }else{
                return true
            }
        }
    }
    var showDashboardLatestCustomers:Bool{
        set(newShowDashboardLatestCustomers){
            SimiDataLocal.setLocalData(data: newShowDashboardLatestCustomers, forKey: (userEmail + "_showDashboardLatestCustomers"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestCustomers") is Bool{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_showDashboardLatestCustomers") as! Bool
            }else{
                return true
            }
        }
    }
    
    var currencyPosition: String{
        set(newCurrencyPosition){
            SimiDataLocal.setLocalData(data: newCurrencyPosition, forKey: (userEmail + "_currencyPosition"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_currencyPosition") as! String == ""{
                return currencyLeftSpace
            }else{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_currencyPosition") as! String
            }
        }
    }
    var decimalNumber: String{
        set(newDecimalNumber){
            SimiDataLocal.setLocalData(data: newDecimalNumber, forKey: (userEmail + "_decimalNumber"))
        }
        get{
            if (SimiDataLocal.getLocalData(forKey: userEmail + "_decimalNumber") as! String) == ""{
                return "2"
            }else{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_decimalNumber") as! String
            }
        }
    }
    var decimalSeparator: String{
        set(newDecimalSeparator){
            SimiDataLocal.setLocalData(data: newDecimalSeparator, forKey: (userEmail + "_decimalSeparator"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_decimalSeparator") as! String == ""{
                return "."
            }else{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_decimalSeparator") as! String
            }
        }
    }
    var thousandsSeparator: String{
        set(newThousandsSeparator){
            SimiDataLocal.setLocalData(data: newThousandsSeparator, forKey: (userEmail + "_thousandsSeparator"))
        }
        get{
            if SimiDataLocal.getLocalData(forKey: userEmail + "_thousandsSeparator") as! String == ""{
                return ","
            }else{
                return SimiDataLocal.getLocalData(forKey: userEmail + "_thousandsSeparator") as! String
            }
        }
    }
    
    func clearUserData(){
        userEmail = ""
        userPassword = ""
        userURL = ""
        qrSessionId = ""
    }
}

