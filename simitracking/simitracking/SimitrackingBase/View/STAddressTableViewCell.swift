//
//  STAddressTableViewCell.swift
//  SimiTracking
//
//  Created by Hai Nguyen on 11/21/16.
//  Copyright © 2016 SimiCart. All rights reserved.
//

import UIKit

class STAddressTableViewCell: SimiTableViewCell {
    func setCellWithInfo(addressData: Dictionary<String, Any>, row: SimiRow) {
        var heightCell = 10
        var firstName = ""
        var lastName = ""
        if !(addressData["firstname"] is NSNull) && addressData["firstname"] != nil{
            firstName = (addressData["firstname"] as? String)!
        }
        if !(addressData["lastname"] is NSNull) && addressData["lastname"] != nil{
            lastName = (addressData["lastname"] as? String)!
        }
        var namevalueString = firstName + " " + lastName
        
        if !(addressData["suffix"] is NSNull) && (addressData["suffix"] != nil) && ((addressData["suffix"] as! String) != "") {
            namevalueString = namevalueString + " " + (addressData["suffix"] as! String)
        }
        
        if !(addressData["prefix"] is NSNull) && (addressData["prefix"] != nil) && ((addressData["prefix"] as! String) != "") {
            namevalueString = (addressData["prefix"] as! String) + " " + namevalueString
        }
        self.addValueLabel(withTitle: STLocalizedString(inputString: "Full Name"), andValue: namevalueString, atHeight: heightCell)
        heightCell += 22
        
        if !(addressData["street"] is NSNull) && (addressData["street"] != nil) && ((addressData["street"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "Street"), andValue: (addressData["street"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        if !(addressData["city"] is NSNull) && (addressData["city"] != nil) && ((addressData["city"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "City"), andValue: (addressData["city"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        
        if !(addressData["region"] is NSNull) && (addressData["region"] != nil) && ((addressData["region"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "State/Region"), andValue: (addressData["region"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        if !(addressData["country_name"] is NSNull) && (addressData["country_name"] != nil) && ((addressData["country_name"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "Country"), andValue: (addressData["country_name"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        
        if !(addressData["telephone"] is NSNull) && (addressData["telephone"] != nil) && ((addressData["telephone"] as! String) != "") {
            addURLLabel(withTitle: STLocalizedString(inputString: "Telephone"), value: (addressData["telephone"] as! String), atHeight: heightCell, urlType: .phoneNumber)
        heightCell += 22
        }
        
        
        if !(addressData["company"] is NSNull) && (addressData["company"] != nil) && ((addressData["company"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "Company"), andValue: (addressData["company"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        
        if !(addressData["fax"] is NSNull) && (addressData["fax"] != nil) && ((addressData["fax"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "Fax"), andValue: (addressData["fax"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        
        if !(addressData["postcode"] is NSNull) && (addressData["postcode"] != nil) && ((addressData["postcode"] as! String) != "") {
            self.addValueLabel(withTitle: STLocalizedString(inputString: "Postcode"), andValue: (addressData["postcode"] as! String), atHeight: heightCell)
            heightCell += 22
        }
        
        
        
        if !(addressData["email"] is NSNull) && (addressData["email"] != nil) && ((addressData["email"] as! String) != "") {
            self.addURLLabel(withTitle: STLocalizedString(inputString: "Email"), value: (addressData["email"] as! String), atHeight: heightCell, urlType: .emailAddress)
            heightCell += 30
        }
        row.height = CGFloat(heightCell)
    }
}
