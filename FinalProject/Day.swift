//
//  Day.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 2/25/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

class Day: NSObject {
    
    /* 
        Class that represents an instance of Day. 
    
        ATTRIBUTES:
            name            : Type      Description
                                            [invariants]
            month           : Month     Represents the month the day resides in.
                                            [Must be a valid Month object]
            dayNumValue     : Int       Represents the day of the month the instance has
                                            [Must be in 1 .. number of days in month]
            dayText         : String    Text data associated with the current Day instance
                                            [Any string]
    */
    
    var month: Month
    var dayNumValue: Int
    var dayText: String = ""
    var stringRepDate: String
    
    init(month: Month, dayNumValue: Int, dayText: String?) {
        
        self.month = month
        self.dayNumValue = dayNumValue
        self.dayText = dayText ?? ""
        self.stringRepDate = "\(month.monthValue)/\(dayNumValue)/\(month.currentYear)"
    }
    
    func getDescription() -> String {
        return self.stringRepDate
    }
    
    func containsData() -> Bool {
        return !self.dayText.isEmpty
    }

}
