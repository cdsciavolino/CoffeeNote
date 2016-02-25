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
    ATTRIBUTES:
        monthName: String value of one of the twelve months
        monthValue: Int representaion of one of the twelve months
        numDaysInMonth: Int value of how many days in specified month
        leapYear: Boolean value passed if the current year is a leap year or not
        firstDayInMonth: Int representation of the first day of the given month according to the following:
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
    var firstDayInMonth: Int
    
    init(month: Int, year: Int) {
        self.monthValue = month
        self.monthName = ""
        self.numDaysInMonth = 0
        self.leapYear = true
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
    
    func isLeapYear(year: Int) -> Bool{
        
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
    
    func getFirstDayInMonth(month: Int, year: Int, leapYear: Bool) -> Int{
        
//      returns the first day in the month in accordance with the chart above
//      Saturday:   0
//      Sunday:     1
//      Monday:     2
//      Tuesday:    3
//      Wednesday:  4
//      Thursday:   5
//      Friday:     6
        
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
