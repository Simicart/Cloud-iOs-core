//
//  SimiTable.swift
//  SimiTracking
//
//  Created by Hoang Van Trung on 1/11/17.
//  Copyright © 2017 SimiCart. All rights reserved.
//

import Foundation

class SimiTable{
    public var sections: Array = Array<SimiSection>()
    
    public func getSectionIndexById(identifier:String) -> Int{
        for section : SimiSection! in sections {
            if(section.identifier == identifier){
                return sections.index(of: section)!
            }
        }
        return 0
    }
    
    public var sectionCount: Int{
        get{
            return sections.count
        }
    }
    
    public func addSectionWithIdentifier(identifier:String) -> SimiSection{
        let section: SimiSection = SimiSection(identifier: identifier)
        self.sections.append(section)
        return section
    }
    
    public func addSection(_ section:SimiSection){
        self.sections.append(section)
    }
    
    public func sectionAtIndex(index: Int) -> SimiSection{
        return sections[index]
    }
    
}
