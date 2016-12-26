//
//  SimiGlobalVar.swift
//  simitracking
//
//  Created by Hai Nguyen on 11/5/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

let CURENT_SIMTRACKING_VERSION = "0.1.0"

let LAST_USER_EMAIL = "last_user_email"

let THEME_COLOR:UIColor =  SimiGlobalVar.colorWithHexString(hexStringInput: "#fc9900")

let SIMI_GET:String = "GET"
let SIMI_POST:String = "POST"
let SIMI_PUT:String = "PUT"
let SIMI_DELETE:String = "DELETE"


// Permissions
let SALE_TRACKING = "1"
let TOTAL_DETAIL = "2"
let SALE_DETAIL = "3"
let PRODUCT_LIST = "4"
let PRODUCT_DETAIL = "5"
let PRODUCT_EDIT = "6"
let CUSTOMER_LIST = "7"
let CUSTOMER_DETAIL = "8"
let CUSTOMER_EDIT = "9"
let CUSTOMER_ADDRESS_LIST = "10"
let CUSTOMER_ADDRESS_EDIT = "11"
let CUSTOMER_ADDRESS_REMOVE = "12"
let ORDER_LIST = "13"
let ORDER_DETAIL = "14"
let INVOICE_ORDER = "15"
let SHIP_ORDER = "16"
let CANCEL_ORDER = "17"
let HOLD_ORDER = "18"
let UNHOLD_ORDER = "19"
let ABANDONED_CARTS_LIST = "20"
let ABANDONED_CARTS_DETAILS = "21"

let PERMISSION_ARRAY = [SALE_TRACKING,TOTAL_DETAIL,SALE_DETAIL,PRODUCT_LIST,PRODUCT_DETAIL,PRODUCT_EDIT,CUSTOMER_LIST,CUSTOMER_DETAIL,CUSTOMER_EDIT,CUSTOMER_ADDRESS_LIST,CUSTOMER_ADDRESS_EDIT,CUSTOMER_ADDRESS_REMOVE,ORDER_LIST,ORDER_DETAIL,INVOICE_ORDER,SHIP_ORDER,CANCEL_ORDER,HOLD_ORDER,UNHOLD_ORDER,ABANDONED_CARTS_LIST,ABANDONED_CARTS_DETAILS]

// Left menu
let DASHBOARD_MENU = "Dashboard_menu"
let ORDER_MENU = "Order_menu"
let BESTSELLERS_MENU = "Bestsellers_menu"
let PRODUCT_MENU = "Product_menu"
let CUSTOMER_MENU = "Customer_menu"
let ABANDONED_CART_MENU = "Abandoned_cart_menu"
let SETTING_MENU = "Setting_menu"
let LOGOUT_MENU = "Logout_menu"

let VERTICAL_LAYOUT_DIRECTION = "_vertical"
let HORIZONTAL_LAYOUT_DIRECTION = "_horizontal"

func STLocalizedString(inputString: String) ->String {
    return SimiGlobalVar.localizedStringForKey(key: inputString)
}

func ImageViewToColor(imageView: UIImageView, color:UIColor) {
    imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
    imageView.tintColor = color
}

func scaleValue(inputSize: CGFloat)->CGFloat {
    return SimiGlobalVar.scaleValue(inputSize: inputSize)
}

class SimiGlobalVar: NSObject {
    //notification
    static var deviceToken:String = ""
    
    //session
    static var baseURL:String = ""
    static var sessionId:String = ""
    static var permissionsAllowed:Dictionary<String, Bool>!
    
    //settings
    static var itemsPerPage = 40
    static var userData:STUserData!
    
    //store informations
    static var storeList:Array<Dictionary<String, Any>>!
    static var selectedStoreId = ""
    static var baseCurrency = ""
    
    //device info
    static var screenWidth:CGFloat = UIScreen.main.bounds.width
    static var screenHeight:CGFloat = UIScreen.main.bounds.height
    static var layoutDirection = ""
    
    //store datatable
    static var productVisibility = ["1":STLocalizedString(inputString: "Not Visible"),"2":STLocalizedString(inputString: "Catalog"),"3":STLocalizedString(inputString: "Search"),"4":STLocalizedString(inputString: "Catalog, Search")]
    
    static func colorWithHexString (hexStringInput:String) -> UIColor {
        let hex = hexStringInput.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    static func localizedStringForKey (key: String)->String {
        if #available(iOS 9.0, *) {
            return key.localizedCapitalized
        } else {
            return key
        }
    }
    
    static func grandPermissions(data: Array<Dictionary<String, String>>) {
        SimiGlobalVar.permissionsAllowed = [:]
        for permissionDefined in PERMISSION_ARRAY {
            SimiGlobalVar.permissionsAllowed[permissionDefined] = false
            let permissionsReturned:Array<Dictionary<String, String>> = data
            for permissionReturned in permissionsReturned {
                if (permissionReturned["permission_id"] == permissionDefined) {
                    SimiGlobalVar.permissionsAllowed[permissionDefined] = true
                }
            }
        }
    }
    
    static func scaleValue(inputSize: CGFloat)->CGFloat {
        return SimiGlobalVar.screenWidth/320 * inputSize
    }
    
    static func getPrice(currency: String, value:String)->String {
        let priceValue = Double(value)
        return (currency + " " + (priceValue?.description)!)
    }
    
    //screen var
    
    static func updateScreenSize(size: CGSize) {
        screenWidth = size.width
        screenHeight = size.height
        updateLayoutDirection()
    }
    
    static func updateLayoutDirection() {
        if(SimiGlobalVar.screenWidth < SimiGlobalVar.screenHeight) {
            layoutDirection = VERTICAL_LAYOUT_DIRECTION
        } else {
            layoutDirection = HORIZONTAL_LAYOUT_DIRECTION
        }
    }
}


