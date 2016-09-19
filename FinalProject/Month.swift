//
//  Month.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/25/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit

class Month: NSObject {

    /*
     Class that represents an instance of a Month
     ATTRIBUTES:
        NAME            : Type     Description
                            [invariants]
        monthName       : String   Name of the corresponding month
                            [One of the 12 months]
        monthValue      : Int      Number of the corresponding month
                            [1..12]
        numDaysInMonth  : Int      Number of days in corresponding month
                            [1..31]
        leapYear        : Bool     Returns if the year is a leap year or not
        currentYear     : Int      Number of the current year
                            [1..]
        firstDayInMonth : Int      Number corresponding to the first day of the month given the following chart:
            Sunday:     0
            Monday:     1
            Tuesday:    2
            Wednesday:  3
            Thursday:   4
            Friday:     5
            Saturday:   6
    */
    
    var monthName: String
    var monthValue: Int
    var numDaysInMonth: Int
    var leapYear: Bool
    var currentYear: Int
    var firstDayInMonth: Int
    
    init(month: Int, year: Int) {
        self.monthValue = month
        self.monthName = ""
        self.numDaysInMonth = 0
        self.leapYear = true
        self.currentYear = year
        self.firstDayInMonth = 0
        super.init()
        self.leapYear = isLeapYear(year)
        self.firstDayInMonth = getFirstDayInMonth(month, year: year, leapYear: self.leapYear)
        if firstDayInMonth == 0 {
            firstDayInMonth = 6
        }
        else {
            firstDayInMonth -= 1
        }
        
        switch month {
        case 1:
            self.monthName = "January"
            self.numDaysInMonth = 31
            break
        case 2:
            self.monthName = "February"
            if(leapYear){
                self.numDaysInMonth = 29
            }
            else {
                self.numDaysInMonth = 28
            }
            break
        case 3:
            self.monthName = "March"
            self.numDaysInMonth = 31
            break
        case 4:
            self.monthName = "April"
            self.numDaysInMonth = 30
            break
        case 5:
            self.monthName = "May"
            self.numDaysInMonth = 31
            break
        case 6:
            self.monthName = "June"
            self.numDaysInMonth = 30
            break
        case 7:
            self.monthName = "July"
            self.numDaysInMonth = 31
            break
        case 8:
            self.monthName = "August"
            self.numDaysInMonth = 31
            break
        case 9:
            self.monthName = "September"
            self.numDaysInMonth = 30
            break
        case 10:
            self.monthName = "October"
            self.numDaysInMonth = 31
            break
        case 11:
            self.monthName = "November"
            self.numDaysInMonth = 30
            break
        case 12:
            self.monthName = "December"
            self.numDaysInMonth = 31
            break
        default:
            self.monthName = "Default Case Run"
            self.numDaysInMonth = 30
            break
        }
    }
    
    
    /*
     Returns whether the year is a leap year or not
     */
    func isLeapYear(_ year: Int) -> Bool{
        
        //returns whether the current year is a leap year or not
        
        if(year % 4 == 0) {
            if(year % 100 == 0 && year % 400 == 0) {
                return true
            }
            else if (year % 100 == 0 && year % 400 != 0) {
                return false
            }
            else{
                return true
            }
        }
        else {
            return false
        }
    }
    
    
    /*
     returns the first day in the month in accordance with the chart below
        Saturday:   0
        Sunday:     1
        Monday:     2
        Tuesday:    3
        Wednesday:  4
        Thursday:   5
        Friday:     6
     */
    func getFirstDayInMonth(_ month: Int, year: Int, leapYear: Bool) -> Int{
        
        var month = month
        let yearNum = year % 100
        let day = 1
        let ycomp = yearNum / 4
        var centuryNum = (year - yearNum) % 4
        switch centuryNum {
        case 0:
            centuryNum = 0
            break
        case 1:
            centuryNum = 5
            break
        case 2:
            centuryNum = 3
            break
        case 3:
            centuryNum = 1
            break
        default:
            break
        }
        
        switch month {
        case 1:
            if leapYear {
                month = 6
            }
            else {
                month = 0
            }
            break
        case 2:
            if leapYear {
                month = 2
            }
            else {
                month = 3
            }
            break
        case 3:
            month = 3
            break
        case 4:
            month = 6
            break
        case 5:
            month = 1
            break
        case 6:
            month = 4
            break
        case 7:
            month = 6
            break
        case 8:
            month = 2
            break
        case 9:
            month = 5
            break
        case 10:
            month = 0
            break
        case 11:
            month = 3
            break
        case 12:
            month = 5
            break
        default:
            month = 0
            break
        }
        return (month + yearNum + day + ycomp + centuryNum) % 7
    }
    
    
    
    
}
