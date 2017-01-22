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
