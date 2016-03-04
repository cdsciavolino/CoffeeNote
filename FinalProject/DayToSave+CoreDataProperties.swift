//
//  DayToSave+CoreDataProperties.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 2/29/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension DayToSave {

    @NSManaged var savedText: String?
    @NSManaged var dateString: String?

}
