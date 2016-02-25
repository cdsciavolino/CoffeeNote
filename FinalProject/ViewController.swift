//
//  ViewController.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/19/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var notepadTF: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lastMonthBarButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDateLabelConstraint: NSLayoutConstraint!
    
    //psuedo-days in month
    var items: [String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
    
    var dataDatesArray: [NSManagedObject] = [] //Storing Item entities. Item has an attribute called 'date'
    // NSManagedObject: a single object stored in Core Data. Use, create, edut, save, and delete from Core Data persistent store
    
    var dataTextArray: [NSManagedObject] = []
    
    var textFieldData: [String: String] = [:]
        
    //flowlayout that formats the UICOllectionView
    lazy var flowLayout: UICollectionViewFlowLayout = {
        
        //standard way of flipping phone sideways
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flow.minimumInteritemSpacing = 0.0
        flow.minimumLineSpacing = 1.0
        flow.itemSize = CGSize(width: 300, height: 300)
        flow.sectionInset.top = 0.0
        return flow
    }()
    
    lazy var todayStringValue: String = {
        let todays = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let day = calendar!.components(.Day, fromDate: todays).day
        let month = calendar!.components(.Month, fromDate: todays).month
        let year = calendar!.components(.Year, fromDate: todays).year
        return "\(month)/\(day)/\(year)"
        
        
    }()
    
    lazy var selectedDay: Int = {
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let day = calendar!.components(.Day, fromDate: today)
        return day.day
        
    }()
    
    lazy var selectedYear: Int = {
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let year = calendar!.components(.Year, fromDate: today)
        return year.year
        
    }()
    
    lazy var selectedMonth: Month = {
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let month = calendar!.components(.Month, fromDate: today)
        let year = calendar!.components(.Year, fromDate: today)
        return Month(month: month.month, year: year.year)
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Helper function that fetches the data from CoreData upon loading in the application
        fetchDatesFromCoreData()
        
        //takes the data int he dataDatesArray and dataTextArray and converts it to the textFieldData dictionary
        if dataTextArray.count != 0 {
            
            for index in 0...dataTextArray.count-1 {
                textFieldData[(dataDatesArray[index].valueForKey("date")) as! String] = dataTextArray[index].valueForKey("savedText") as? String
            }
        }
    
        //Setting up notifications when keyboard comes up/recedes
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        //setting up calendar data
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let month: NSDateComponents = (calendar?.components(.Month, fromDate: today))!
        let day: NSDateComponents = (calendar?.components(.Day, fromDate: today))!
        let year = calendar?.components(.Year, fromDate: today)
        let currentMonthData = Month(month: month.month, year: (year?.year)!)
        
        //initializes values
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        notepadTF.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        dateLabel.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        dateLabel.textColor = UIColor.whiteColor()
        notepadTF.textColor = UIColor.whiteColor()
        
        self.title = "\(currentMonthData.monthName) \(year!.year)"
        dateLabel.text = "\(currentMonthData.monthName) \(day.day), \(year!.year)"
        var counter = 1
        for x in currentMonthData.firstDayInMonth...(currentMonthData.numDaysInMonth + currentMonthData.firstDayInMonth) {
            items[x] = String(counter)
            if counter == currentMonthData.numDaysInMonth {
                counter = 0
                break
            }
            counter += 1
        }
//        uncomment if you want to implement days in the beginning and end of the collectionView
        
//        let priorMonth = Month(month: month.month-1, year: selectedYear)
//        var num = priorMonth.numDaysInMonth
//        let numToChange = (0...currentMonthData.firstDayInMonth-1).count - 1
//        num -= numToChange
//        for x in 0...currentMonthData.firstDayInMonth-1 {
//            items[x] = num
//            num += 1
//        }
        
        //takes away the gap at the top of the collectionView
        self.automaticallyAdjustsScrollViewInsets = false
        
        //formats the collectionView
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        collectionView.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        flowLayout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 35)
        
        //what we had before autolayout; given a frame, expand the view to fit into new frame
    }
    

    override func viewDidAppear(animated: Bool) {
        notepadTF.textColor = UIColor.whiteColor()
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //creates unique sizes for each cell
        
        let width = view.bounds.width / 8.0
        let height = view.bounds.height / 13.5
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //method that runs this code when a certain cell is selected
        
        let dest = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        notepadTF.editable = true
        notepadTF.selectable = true
        dest.selectionView.alpha = 0.8
        dateLabel.text = "\(dest.month.monthName) \(dest.label.text!), \(dest.year)"
        
        //if selected, need to toggle in order to get the buttons to trigger correctly
        dest.selected = true
        
        selectedDay = Int(dest.label.text!)!
        
        //following searches the dictionary for the key (date) to see if there is any text. Else, it makes it default
        let newString = String(dest.month.monthValue) + "/" + String(dest.label.text!) + "/" + String(dest.year)
        if let loadedData = textFieldData[newString] {
            notepadTF.text = loadedData
        } else {
//            notepadTF.text = String(dest.month.monthName) + " " + String(dest.label.text!) + ", " + String(dest.year)
            notepadTF.text = ""
        }
        notepadTF.font = notepadTF.font?.fontWithSize(18.0)
    }
    
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        //method that runs this code when the cell is deselected
        
        let dest = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
        //if selected, need to toggle in order to get the buttons to trigger correctly
        dest.selected = false
        
        dest.selectionView.alpha = 0.0
        view.endEditing(true)
        
        if "\(dest.month.monthValue)/\(dest.label.text!)/\(dest.year)" == todayStringValue {
            dest.selectionView.backgroundColor = UIColor(red: 138/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            dest.selectionView.alpha = 0.8
        }
        
        //following searches the dictionary for the key (date) to see if there is any text. Else, it makes it default
        let stringRep = String(dest.month.monthValue) + "/" + String(dest.label.text!) + "/" + String(dest.year)
        
        // Saves the data when the cell is deselected
        saveDateData(stringRep, textDataToSave: notepadTF.text)
        
        if textFieldData.keys.contains(stringRep) {
            textFieldData[stringRep] = notepadTF.text
        } else {
            textFieldData[stringRep] = notepadTF.text ?? ""
        }
        
        //hasDataSelectionViewFormatting
        dest.hasDataSelectionView.layer.cornerRadius = dest.hasDataSelectionView.frame.width / 2.0
        dest.hasDataSelectionView.alpha = 0.0
        if textFieldData.keys.contains(stringRep) && textFieldData[stringRep] != "" {
            dest.hasDataSelectionView.alpha = 0.8
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //formats and fills each cell according to the class CollectionViewCell
//        print("setting up cells")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        cell.label.text = String(items[indexPath.row])
        cell.month = selectedMonth
        cell.year = selectedYear
        cell.selectionView.backgroundColor = UIColor.orangeColor()
        cell.selectionView.layer.cornerRadius = cell.frame.width / 2.0
        cell.label.textColor = UIColor.whiteColor()
        let stringRep = "\(cell.month.monthValue)/\(cell.label.text!)/\(cell.year)"
        if stringRep == todayStringValue {
            cell.selectionView.backgroundColor = UIColor(red: 138/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            cell.selectionView.alpha = 0.8
        }
        
        //if the label is empty then the user cannot crash the program by pressing it
        if cell.label.text == "" {
            cell.userInteractionEnabled = false
        }
        else {
            cell.userInteractionEnabled = true
        }
        
        //hasDataSelectionView Formatting
        cell.hasDataSelectionView.layer.cornerRadius = cell.hasDataSelectionView.frame.width / 2.0
        cell.hasDataSelectionView.alpha = 0.0
        if textFieldData.keys.contains(stringRep) && textFieldData[stringRep] != "" {
            cell.hasDataSelectionView.alpha = 0.8
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //returns number of items in the collectionView
        
        return items.count
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        //formats and develops the current header view
        
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! WeekdayCollectionReusableView
        view.weekdayCollectionView.delegate = view.self
        view.weekdayCollectionView.dataSource = view.self
        return view
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        
        //tapping elsewhere dismisses keyboard
        
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    
    //Calls lastMonth() helper method
    @IBAction func lastMonthButtonPressed(sender: UIBarButtonItem) {
        lastMonth()
    }
    
    
    //Calls nextMonth() helper method
    @IBAction func nextMonthButtonPressed(sender: UIBarButtonItem) {
        nextMonth()
    }
    
    
    //Calls helper method lastMonth when the user swipes the screen right
    @IBAction func screenSwiped(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .Right {
            lastMonth()
        }
        
    }
    
    
    //Calls helper method nextMonth() when the user swipes the screen left
    @IBAction func screenSwipedLeft(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .Left {
            nextMonth()
        }
        
    }
    
    
    // Moves the notepadTF up when the keyboard is about to show up
    func keyboardWillShow(notif: NSNotification) {
        let info = notif.userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        bottomTextFieldConstraint.constant += h
        topDateLabelConstraint.constant -= h
        collectionView.alpha = 0.0
        
    }
    
    
    // Moved the notepadTF back down when the user dismisses the keyboard
    func keyboardWillHide(notif: NSNotification) {
        let info = notif.userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        bottomTextFieldConstraint.constant -= h
        topDateLabelConstraint.constant += h
        collectionView.alpha = 1.0
        
    }
    
    
    func generateItemsArray(selectedMonthData: Month, selectedYear: Int) -> [String] {
        
        /*
        Parameters: selectedMonthData: Month
                        represents the current month that the calendar will be
                    selectedYear: Int
                        represents the current year of the calendar section
        Returns:    [String]
                        the new items list that contains a list of strings that stand for the days of the month
        
        Used for:
            generating a new items array with days of that specific month
        
        How it works:
            first, parses the array and sets everything equal to null set
            second, parses the array starting at the index of the firstDayInMonth, so it reflects the first weekday
            returns itemsArray
        */
        
        var counter = 1
        var itemsArray: [String] = []
        for _ in 0...items.count-1 {//selectedMonthData.firstDayInMonth-1 {
            itemsArray.append("")
        }
        for x in selectedMonthData.firstDayInMonth...itemsArray.count - 1 { //(selectedMonthData.numDaysInMonth + selectedMonthData.firstDayInMonth + 1) {
            itemsArray[x] = String(counter)//.append(String(counter))
            if counter == selectedMonthData.numDaysInMonth {
                counter = 0
                break
            }
//            print(counter)
            counter += 1
        }
//        print(itemsArray)
//        print("Num days in month is \(selectedMonthData.numDaysInMonth)")
//        print(selectedMonthData.firstDayInMonth)
//        print(itemsArray.count)
    
//        uncomment if you want days to be filled in the first and last cells
        
//        if selectedMonthData.firstDayInMonth != 0 {
//            let priorMonth = Month(month: selectedMonthData.monthValue-1, year: selectedYear)
//            var num = priorMonth.numDaysInMonth
//            let numToChange = (0...selectedMonthData.firstDayInMonth-1).count - 1
//            num -= numToChange
//            for x in 0...selectedMonthData.firstDayInMonth-1 {
//                itemsArray[x] = num
//                num += 1
//            }
//      }
        return itemsArray
    }
    
    
    func nextMonth() {
        
        /*
        Action to switch the month to the next month
        
        How it works:
        if the selected month value is 12, then it increments the year and sets the month to January
        else it just increments the monthValue of the current month and reloads the data of the table reflect the change
        
        Latter half:
        resets all of the cells to be deselected while saving the data if the cell was selected
        **something to do in the future**
        when changing the month, reset the text field to "Select a day to proceed"
        
        change the content size for the collectionView if the number of rows are not enough
        Ex. August 2015 does not have enough cells currently
        */
        
        if selectedMonth.monthValue == 12 {
            selectedMonth = Month(month: 1, year: selectedYear + 1)
            selectedYear += 1
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue + 1, year: selectedYear)
        }
        //        print(collectionView.intrinsicContentSize())
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        items = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        
        //latter half starts here
        for x in 0...items.count-1 {
            let dest = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: x, inSection: 0)) as! CollectionViewCell
            dest.selectionView.alpha = 0.0
            let stringRep = String(dest.month.monthValue) + "/" + String(dest.label.text!) + "/" + String(dest.year)
            if dest.selected {
                textFieldData[stringRep] = notepadTF.text
                
                // Saves the data in the current selected cell when the nextMonth() button is pressed
                saveDateData(stringRep, textDataToSave: notepadTF.text)
                
                dest.selected = false
            }
            collectionView.deselectItemAtIndexPath(NSIndexPath(forRow: x, inSection: 0), animated: false)
        }
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    func lastMonth() {
        
        /*
        Action to switch the month to the prior month
        
        How it works:
        if the selected month value is 1, then it decrements the year and sets the month to December
        else it just decrements the monthValue of the current month and reloads the data of the table reflect the change
        
        Latter half:
        resets all of the cells to be deselected while saving the data if the cell was selected
        **something to do in the future**
        when changing the month, reset the text field to "Select a day to proceed"
        
        change the content size for the collectionView if the number of rows are not enough
        Ex. August 2015 does not have enough cells currently
        */
        
        if selectedMonth.monthValue == 1 {
            selectedMonth = Month(month: 12, year: selectedYear - 1)
            selectedYear -= 1
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue - 1, year: selectedYear)
        }
        //        print(collectionView.contentSize)
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        items = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        
        //latter half starts here
//        print("Items array: \(items)")
//        print("number of elements in items array \(items.count)")
        for x in 0...items.count-1 {
//            print("Final iteration crashed on \(x)")
//            print(collectionView.numberOfItemsInSection(0))
//            let checking = (collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: x, inSection: 0)) as! CollectionViewCell).label.text != "" ?? "did not correctly work"
//            print("Label text: \(checking)")
            let dest = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: x, inSection: 0)) as! CollectionViewCell
            dest.selectionView.alpha = 0.0
            let stringRep = String(dest.month.monthValue) + "/" + String(dest.label.text!) + "/" + String(dest.year)
            if dest.selected == true {
                textFieldData[stringRep] = notepadTF.text
    
                //Saves the data in the current selected cell when the user taps the lastMonth button
                saveDateData(stringRep, textDataToSave: notepadTF.text)
                
                dest.selected = false
            }
            collectionView.deselectItemAtIndexPath(NSIndexPath(forRow: x, inSection: 0), animated: false)
        }
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    func saveDateData(date: String, textDataToSave: String) {
        
        /*
        Helper method that saves data to the corresponding [NSManagedObject]
        
        Parameters:
            date:           String: A specified date in the form MM/DD/YYYY to be saved in the dataDatesArray
            textDataToSave  String: A text field that is in any form to be saved in the dataTextArray

        */
        
        
        //retureive the managed object context in the app delegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //add an item to the managed object context
        let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: managedContext)
        let secondEntity = NSEntityDescription.entityForName("ItemTwo", inManagedObjectContext: managedContext)
        let item = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        let itemTwo = NSManagedObject(entity: secondEntity!, insertIntoManagedObjectContext: managedContext)
        
        //set the value for the item
        
        // searches dataDatesArray to see if there is a date in the array. Uncomment portion to  try and filter when to save and when not to save.
        
//        var shouldAddDate = true
//        for x in dataDatesArray {
//            if (x.valueForKey("date") as! String) == date {
//                print("Nested if statement ran")
//                shouldAddDate = false
//            }
//        }
//        if shouldAddDate {
//            item.setValue(date, forKey: "date")
//            
//            //Save the managed object context back
//            do {
//                try managedContext.save()
//            } catch {
//                print("Did not save properly")
//            }
//        }
        
        // Saves the two values in their corresponding entities
        item.setValue(date, forKey: "date")
        itemTwo.setValue((textDataToSave ?? ""), forKey: "savedText")
        
        //Save the managed object context back
        do {
            try managedContext.save()
        } catch {
            print("Did not save properly")
        }
        
    }
    
    
    func fetchDatesFromCoreData() {
        
        /*
        Helper method to fetch the data from CoreData when called
        */
        
        // Get the managedObject context
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        // Create a fetch request into Core Data
        let fetchRequest = NSFetchRequest(entityName: "Item")
        let fetchRequestTwo = NSFetchRequest(entityName: "ItemTwo")
        
        // Execute the fetch request
        do {
            
            let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
                if fetchedResults.count != 0 {
                    dataDatesArray = fetchedResults
                }
        } catch {
            print("could not fetch date data")
        }
        
        do {
            let fetchedResultsTwo = try managedObjectContext.executeFetchRequest(fetchRequestTwo) as! [NSManagedObject]
            if fetchedResultsTwo.count != 0 {
                dataTextArray = fetchedResultsTwo
            }
        } catch {
                print("Coult not fetch the text field data from Core Data")
        }
        
    }
    
    
    func deleteAllData(entity: String) {
        
        /*
        Helper method that is currently not being called anywhere in the above code.
        Deletes all data within the CoreData stack
        */
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}

