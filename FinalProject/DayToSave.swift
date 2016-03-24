//
//  DayToSave.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 2/29/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import Foundation
import CoreData


class DayToSave: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    var month: Month?
    var dayNumValue: Int?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
//    init(month: Month, dayNumValue: Int, dayText: String?) {
//        super.init()
//        self.month = month
//        self.dayNumValue = dayNumValue
//        self.savedText = dayText ?? ""
//        self.dateString = "\(month.monthValue)/\(dayNumValue)/\(month.currentYear)"
//    }
    
    func getDescription() -> String {
        return self.dateString!
    }
    
    func configureDateString() {
        self.dateString = "\(month!.monthValue)/\(dayNumValue!)/\(month!.currentYear)"
    }
    
    func containsData() -> Bool {
        return !self.savedText!.isEmpty
    }

}
