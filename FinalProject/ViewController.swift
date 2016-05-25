//
//  ViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 11/19/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!                //Connection to the upper calendar
    @IBOutlet weak var notepadTF: UITextView!                           //Connection to the lower notepad
    @IBOutlet weak var dateLabel: UILabel!                              //Connection to the middle label with the date
    @IBOutlet weak var lastMonthButton: UIButton!                       //Connection to the "Last Month" button
    @IBOutlet weak var nextMonthButton: UIButton!                       //Connection to the "Next Month" button
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!   //Connection to the bottom constraint on the notepad
    @IBOutlet weak var topDateLabelConstraint: NSLayoutConstraint!      //Connection to the upper constrain on the date label
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var previouslySavedDaysArray: [DayToSave] = []      //Create an array to hold all the NSManagedObjects pulled from CoreData
    var dayDictionary: [String : Day] = [:]             //Create a dictionary to handle each of the date - Day pairs to save
    var monthCollectionArray: [Day] = []                //Create an array of Days to be handled by the collectionView
    
    var keyboardIsShowingAlready: Bool = false          //Bool to help with keyboardWillShow and KeyboardWillHide methods
    
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
        /*  
         Int value of the currently selected day.
         *** Cannot be used if a day is not selected in the calendar view ***
        */
        
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let day = calendar!.components(.Day, fromDate: today)
        return day.day
    }()
    
    lazy var selectedYear: Int = {
        /*
         Int value of the currently selected year.
        */
        
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let year = calendar!.components(.Year, fromDate: today)
        return year.year
    }()
    
    lazy var selectedMonth: Month = {
        /*
         Int value of the currently selected month.
        */
        
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
        grabDaysForDictionary()
        
        //takes the data int he dataDatesArray and dataTextArray and converts it to the textFieldData dictionary
        
        //Setting up notifications when keyboard comes up/recedes
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.applicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardChanged(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //setting up calendar data
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let month: NSDateComponents = (calendar?.components(.Month, fromDate: today))!
        let day: NSDateComponents = (calendar?.components(.Day, fromDate: today))!
        let year = calendar?.components(.Year, fromDate: today)
        let currentMonthData = Month(month: month.month, year: (year?.year)!)
        
        monthCollectionArray = generateItemsArray(Month(month: currentMonthData.monthValue, year: selectedYear), selectedYear: (year?.year)!)
        
        //initializes values
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        notepadTF.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        dateLabel.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        dateLabel.textColor = UIColor.whiteColor()
        notepadTF.textColor = UIColor.whiteColor()
        
        self.title = "\(currentMonthData.monthName) \(year!.year)"
        dateLabel.text = "\(currentMonthData.monthName) \(day.day), \(year!.year)"
        
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
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //creates unique sizes for each cell
        
        let width = view.bounds.width / 8.0
        let height = view.bounds.height / 13.5
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        /* 
         Method is called whenever the user taps a valid cell in the calendar.
        */
        
        let dest = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        notepadTF.editable = true       //make the text field selectable and editable to add data to the day
        notepadTF.selectable = true
        dest.selectionView.alpha = 0.8
        dateLabel.text = "\(dest.dayRep.month.monthName) \(dest.label.text!), \(dest.dayRep.month.currentYear)"
        
        //if selected, need to toggle in order to get the buttons to trigger correctly
        dest.selected = true
        dest.userInteractionEnabled = false
        
        selectedDay = dest.dayRep.dayNumValue
        
        notepadTF.text = dest.dayRep.dayText
        notepadTF.font = notepadTF.font?.fontWithSize(18.0)
    }
    
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        //method that runs this code when the cell is deselected
        
        let dest = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionViewCell
        
        //if selected, need to toggle in order to get the buttons to trigger correctly
        dest.selected = false
        dest.userInteractionEnabled = true
        
        dest.selectionView.alpha = 0.0
        view.endEditing(true)
        
        if dest.dayRep.getDescription() == todayStringValue {
            dest.selectionView.backgroundColor = UIColor(red: 138/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            dest.selectionView.alpha = 0.8
        }
        
        //following searches the dictionary for the key (date) to see if there is any text. Else, it makes it default
        
        
        //hasDataSelectionViewFormatting
        dest.hasDataSelectionView.layer.cornerRadius = dest.hasDataSelectionView.frame.width / 2.0
        dest.hasDataSelectionView.alpha = 0.0
        if dest.dayRep.containsData() {
            dest.hasDataSelectionView.alpha = 0.8
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //formats and fills each cell according to the class CollectionViewCell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        cell.selected = false
        cell.selectionView.alpha = 0.0
        cell.dayRep = monthCollectionArray[indexPath.row]
        if cell.dayRep.dayNumValue == 0 {
            cell.label.text = ""
        } else {
            cell.label.text = String(cell.dayRep.dayNumValue)
        }
        //
        //Formats the selectionView circle to show up for selected day
        cell.selectionView.backgroundColor = UIColor.orangeColor()
        cell.selectionView.layer.cornerRadius = cell.frame.width / 2.0
        cell.label.textColor = UIColor.whiteColor()
        cell.hasDataSelectionView.layer.cornerRadius = cell.hasDataSelectionView.frame.width / 2.0
        //If the selectedDay is today, then retain the today color
        if cell.dayRep.getDescription() == todayStringValue {
            cell.selectionView.backgroundColor = UIColor(red: 138/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)
            cell.selectionView.alpha = 0.8
        }
        
        //if the label is empty then the user cannot crash the program by pressing it
        if cell.label.text == "" {
            cell.userInteractionEnabled = false
        } else {
            cell.userInteractionEnabled = true
        }
        //
        
        //Small dot above date if the day contains data formatting
        cell.hasDataSelectionView.alpha = 0.0
        if cell.dayRep.containsData() {
            cell.hasDataSelectionView.alpha = 0.8
        }
        //
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //returns number of items in the collectionView
        
        return monthCollectionArray.count
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
    @IBAction func lastMonthButtonPressed(sender: UIButton) {
        lastMonth()
    }
    
    
    //Calls nextMonth() helper method
    @IBAction func nextMonthButtonPressed(sender: UIButton) {
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
        
        self.title = "\(selectedMonth.monthName) \(selectedDay), \(selectedYear)"
        dateLabel.text = "Tap to Save"
        
        lastMonthButton.enabled = false
        nextMonthButton.enabled = false
        lastMonthButton.alpha = 0.0
        nextMonthButton.alpha = 0.0
        
        

        if !keyboardIsShowingAlready {
            bottomTextFieldConstraint.constant = 20 + h
            topDateLabelConstraint.constant = 8 - h
            collectionView.alpha = 0.0
            keyboardIsShowingAlready = true
        }
        
    }
    
    
    // Moved the notepadTF back down when the user dismisses the keyboard
    func keyboardWillHide(notif: NSNotification) {
        let info = notif.userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        
        bottomTextFieldConstraint.constant -= h
        topDateLabelConstraint.constant += h
        collectionView.alpha = 1.0
        keyboardIsShowingAlready = false
        
        lastMonthButton.enabled = true
        nextMonthButton.enabled = true
        lastMonthButton.alpha = 1.0
        nextMonthButton.alpha = 1.0
        
        self.title = "\(selectedMonth.monthName) \(selectedYear)"
        dateLabel.text = "\(selectedMonth.monthName) \(selectedDay), \(selectedYear)"
        
        let dest = collectionView.cellForItemAtIndexPath(collectionView.indexPathsForSelectedItems()![0]) as! CollectionViewCell
        // Saves the data when the cell is deselected
        dest.dayRep.dayText = notepadTF.text ?? ""
        if dest.dayRep.containsData() {
            dayDictionary[dest.dayRep.getDescription()] = dest.dayRep
            saveDateData(dest.dayRep)
        } else {
            dayDictionary.removeValueForKey((dest.dayRep?.getDescription())!)
            //updateObjectFromContext(dest.dayRep)
            //removeObjectFromContext(dest.dayRep)
            // TODO: want to delete this Day from the context ***
        }
        
    }
    
    func keyboardChanged(notif: NSNotification) {
        let info = notif.userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().height
        bottomTextFieldConstraint.constant = h + 20
        topDateLabelConstraint.constant = 8 - h
    }
    
    
    func generateItemsArray(selectedMonthData: Month, selectedYear: Int) -> [Day] {
        
        /*
        PARAMETER           : TYPE      DESCRIPTION
        
        selectedMonthData   : Month     Represents the current selected month to create array for
        selectedYear        : Int       Represents the current selected year to create the array for
        */
        
        var newItemsArray: [Day] = []
        var counter = 1
        
        if selectedMonthData.firstDayInMonth != 0 {
            for _ in 0 ... selectedMonthData.firstDayInMonth - 1 {
                let emptyDay: Day = Day(month: selectedMonthData, dayNumValue: 0, dayText: "")
                newItemsArray.append(emptyDay)
            }
        }
        
        for _ in selectedMonthData.firstDayInMonth ... (selectedMonthData.numDaysInMonth + selectedMonthData.firstDayInMonth - 1) {
            //gets the current data in the dictionary if it exists
            let currentDayTextValue = dayDictionary[toDateForm(selectedMonthData, dayValue: counter)]?.dayText ?? ""
            let newDay: Day = Day(month: selectedMonthData, dayNumValue: counter, dayText: currentDayTextValue)
            newItemsArray.append(newDay)
            counter += 1
        }
        
        return newItemsArray
        
    }
    
    func toDateForm(month: Month, dayValue: Int) -> String {
        
        return "\(month.monthValue)/\(dayValue)/\(month.currentYear)"
        
    }
    
    func grabDaysForDictionary() {
        
        for savedDay in previouslySavedDaysArray {
            dayDictionary[savedDay.dateString!] = Day(month: Month(month: getMonthFromString(savedDay.dateString!), year: getYearFromString(savedDay.dateString!)), dayNumValue: getDayFromString(savedDay.dateString!), dayText: savedDay.savedText!)
        }
        
    }
    
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the MM portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
     */
    func getMonthFromString(dateString: String) -> Int {
        
        let x = dateString.characters.indexOf("/")
        return Int(dateString.substringToIndex(x!))!
        
    }
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the DD portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
    */
    func getDayFromString(dateString: String) -> Int {
        
        let indexOne = dateString.characters.indexOf("/")?.advancedBy(1)
        let string = dateString.substringFromIndex(indexOne!)
        let secondIndex = string.characters.indexOf("/")
        return Int(String(string.substringToIndex(secondIndex!)))!
        
    }
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the YYYY portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
     */
    func getYearFromString(dateString: String) -> Int {
        
        let year = Int(String(dateString.characters.suffix(4)))
        return year!
        
    }
    
    
    func nextMonth() {
        
        /*
        Action to switch the month to the next month
        */
        
        if (collectionView.indexPathsForSelectedItems()!.count != 0) {
            let cell = collectionView.cellForItemAtIndexPath(collectionView.indexPathsForSelectedItems()![0]) as! CollectionViewCell
            cell.dayRep.dayText = notepadTF.text ?? ""
            if cell.dayRep.containsData() {
                dayDictionary[cell.dayRep.getDescription()] = cell.dayRep
            } else {
                dayDictionary.removeValueForKey((cell.dayRep?.getDescription())!)
            }
        }
        
        if selectedMonth.monthValue == 12 {
            selectedMonth = Month(month: 1, year: selectedYear + 1)
            selectedYear += 1
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue + 1, year: selectedYear)
        }
        //        print(collectionView.intrinsicContentSize())
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        monthCollectionArray = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        
        
        collectionView.reloadData()
        
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        notepadTF.editable = false
        notepadTF.selectable = false
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    func lastMonth() {
        
        /*
        Action to switch the month to the prior month
        */
        
        if (collectionView.indexPathsForSelectedItems()!.count != 0) {
            let cell = collectionView.cellForItemAtIndexPath(collectionView.indexPathsForSelectedItems()![0]) as! CollectionViewCell
            cell.dayRep.dayText = notepadTF.text ?? ""
            if cell.dayRep.containsData() {
                dayDictionary[cell.dayRep.getDescription()] = cell.dayRep
            } else {
                dayDictionary.removeValueForKey((cell.dayRep?.getDescription())!)
            }
        }
        
        if selectedMonth.monthValue == 1 {
            selectedMonth = Month(month: 12, year: selectedYear - 1)
            selectedYear -= 1
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue - 1, year: selectedYear)
        }
        //        print(collectionView.contentSize)
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        monthCollectionArray = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        collectionView.reloadData()
        
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        notepadTF.editable = false
        notepadTF.selectable = false
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    func saveDateData(day: Day) {
        
        /*
        Helper method that saves data to the corresponding [NSManagedObject]
        
        Parameters:
        date:           String: A specified date in the form MM/DD/YYYY to be saved in the dataDatesArray
        textDataToSave  String: A text field that is in any form to be saved in the dataTextArray
        
        */
        
        //add an item to the managed object context
        let entity = NSEntityDescription.insertNewObjectForEntityForName("DayToSave", inManagedObjectContext: managedObjectContext) as! DayToSave
        entity.savedText = day.dayText
        entity.dateString = day.getDescription()
        //set the value for the item
        
        // searches dataDatesArray to see if there is a date in the array. Uncomment portion to  try and filter when to save and when not to save.
        
        //Save the managed object context back
        do {
            try managedObjectContext.save()
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
        let fetchRequest = NSFetchRequest(entityName: "DayToSave")
        
        let sortDescriptor = NSSortDescriptor.init(key: "dateString", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Execute the fetch request
        do {
            
            let fetchedResults = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            if fetchedResults.count != 0 {
                self.previouslySavedDaysArray = fetchedResults as! [DayToSave]
            }
        } catch {
            print("could not fetch day data")
        }
        
    }
    
    
    func applicationWillResignActive(notif: NSNotification) {
        //day dictionary
        deleteAllData("DayToSave")
        for string in dayDictionary.keys {
            let entity = NSEntityDescription.insertNewObjectForEntityForName("DayToSave", inManagedObjectContext: managedObjectContext) as! DayToSave
            entity.savedText = dayDictionary[string]!.dayText
            entity.dateString = dayDictionary[string]!.getDescription()
            managedObjectContext.insertObject(entity)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("managed object context not properly saved")
        }
    }
    
    func deleteAllData(entity: String) {
        
        /*
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

