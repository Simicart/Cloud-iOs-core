//
//  SimiFormatter.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/11/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import Foundation

func dateToString(date:Date, format:String) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return  formatter.string(from: date)
}

func localDateFrom(_ dateString:String,timeZone:String, format:String) -> String{
    // create dateFormatter with UTC time format
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
    let date = dateFormatter.date(from: dateString)// create   date from string
    
    // change to a readable time format and change to local time zone
    dateFormatter.timeZone = NSTimeZone.local
    return dateFormatter.string(from: date!)
}

func stringToDate(dateString:String, format:String) -> Date{
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.date(from: dateString)!
}

func splitDate(date:Date) -> (day:String,month:String,year:String){
    let calendar = Calendar.autoupdatingCurrent
    let components = calendar.dateComponents([.day,.month,.year], from: date)
    return ("\(components.day)","\(components.month)","\(components.year)")
}

class SimiFormatter{
    
}
