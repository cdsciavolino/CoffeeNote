//
//  ViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 11/19/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, SettingsUpdatedDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!                //Connection to the upper calendar
    @IBOutlet weak var notepadTF: UITextView!                           //Connection to the lower notepad
    @IBOutlet weak var dateLabel: UILabel!                              //Connection to the middle label with the date
    @IBOutlet weak var lastMonthButton: UIButton!                       //Connection to the "Last Month" button
    @IBOutlet weak var nextMonthButton: UIButton!                       //Connection to the "Next Month" button
    @IBOutlet weak var bottomTextFieldConstraint: NSLayoutConstraint!   //Connection to the bottom constraint on the notepad
    @IBOutlet weak var topDateLabelConstraint: NSLayoutConstraint!      //Connection to the upper constrain on the date label
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!              //Connection to the "Settings" Bar Button
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint! //Constraint between the calendar and the dateLabel
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var previouslySavedDaysArray: [DayToSave] = []      //Create an array to hold all the NSManagedObjects pulled from CoreData
    var dayDictionary: [String : Day] = [:]             //Create a dictionary to handle each of the date - Day pairs to save
    var monthCollectionArray: [Day] = []                //Create an array of Days to be handled by the collectionView
    
    var keyboardIsShowingAlready: Bool = false          //Bool to help with keyboardWillShow and KeyboardWillHide methods
    
    let DEFAULT_COLOR_SCHEME: ColorScheme = ColorScheme.darkGreyScheme()
    let COLOR_SCHEMES_ARRAY: [String : ColorScheme] =
        [ColorScheme.darkGreyScheme().colorSchemeName : ColorScheme.darkGreyScheme(),
         ColorScheme.darkBlueScheme().colorSchemeName : ColorScheme.darkBlueScheme()]
    
    lazy var currentColorScheme: ColorScheme = {
        let COLOR_SCHEMES_ARRAY: [String : ColorScheme] =
            [ColorScheme.darkGreyScheme().colorSchemeName : ColorScheme.darkGreyScheme(),
             ColorScheme.darkBlueScheme().colorSchemeName : ColorScheme.darkBlueScheme()]
        
        var colorSchemeName = UserDefaults.standard.object(forKey: "ColorSchemeName") as? String ?? ColorScheme.darkGreyScheme().colorSchemeName
        var colorScheme: ColorScheme = COLOR_SCHEMES_ARRAY[colorSchemeName]!
        
        return colorScheme
    }()

    
    /* 
     Flowlayout that formats the UICollectionView 
     */
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
    
    
    /* 
     String value of the current day 
     */
    lazy var todayStringValue: String = {
        let todays = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar).components(.day, from: todays).day!
        let month = (calendar as NSCalendar).components(.month, from: todays).month!
        let year = (calendar as NSCalendar).components(.year, from: todays).year!
        return "\(month)/\(day)/\(year)"
    }()
    
    
    /*
     Int value of the currently selected day.
     *** Cannot be used if a day is not selected in the calendar view ***
     */
    lazy var selectedDay: Int = {
        let today = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar).components(.day, from: today)
        return day.day!
    }()
    
    
    /*
     Int value of the currently selected year.
     */
    lazy var selectedYear: Int = {
        let today = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let year = (calendar as NSCalendar).components(.year, from: today)
        return year.year!
    }()
    
    
    /*
     Int value of the currently selected month.
     */
    lazy var selectedMonth: Month = {
        let today = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let month = (calendar as NSCalendar).components(.month, from: today)
        let year = (calendar as NSCalendar).components(.year, from: today)
        return Month(month: month.month!, year: year.year!)
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Update background color
        self.view.backgroundColor = currentColorScheme.backGroundColor
        
        //Update notepadTF colors
        notepadTF.backgroundColor = currentColorScheme.backGroundColor
        notepadTF.textColor = currentColorScheme.textColor
        notepadTF.layer.borderColor = currentColorScheme.secondaryColor.cgColor
        notepadTF.layer.cornerRadius = 5
        notepadTF.layer.borderWidth = 3
        
        //Update dateLabel colors
        dateLabel.backgroundColor = currentColorScheme.backGroundColor
        dateLabel.textColor = currentColorScheme.textColor
        
        //Update calendar color
        collectionView.backgroundColor = currentColorScheme.backGroundColor
        
        //Update navigation bar colors
        self.navigationController?.navigationBar.backgroundColor = currentColorScheme.navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: currentColorScheme.textColor]
        settingsBarButton.tintColor = currentColorScheme.textColor
        nextMonthButton.titleLabel?.textColor = currentColorScheme.textColor
        lastMonthButton.titleLabel?.textColor = currentColorScheme.textColor
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Helper function that fetches the data from CoreData upon loading in the application
        fetchDatesFromCoreData()
        grabDaysForDictionary()
        
        //Setting up notifications when keyboard comes up/recedes and when the application gets sent to the background
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationWillResignActive(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardChanged(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.applicationDidEnterBackground(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        //setting up calendar data
        let today = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let month: DateComponents = ((calendar as NSCalendar?)?.components(.month, from: today))!
        let day: DateComponents = ((calendar as NSCalendar?)?.components(.day, from: today))!
        let year = (calendar as NSCalendar?)?.components(.year, from: today)
        let currentMonthData = Month(month: month.month!, year: (year?.year)!)
        self.title = "\(currentMonthData.monthName) \(year!.year!)"
        dateLabel.text = "\(currentMonthData.monthName) \(day.day!), \(year!.year!)"
        
        monthCollectionArray = generateItemsArray(Month(month: currentMonthData.monthValue, year: selectedYear), selectedYear: (year?.year)!)
        
        //initializes values and colors
        self.view.backgroundColor = currentColorScheme.backGroundColor
        notepadTF.backgroundColor = currentColorScheme.secondaryColor
        dateLabel.backgroundColor = currentColorScheme.secondaryColor
        dateLabel.textColor = currentColorScheme.textColor
        notepadTF.textColor = currentColorScheme.textColor
        self.navigationController?.navigationBar.backgroundColor = currentColorScheme.navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: currentColorScheme.textColor]
        settingsBarButton.tintColor = currentColorScheme.textColor
        nextMonthButton.tintColor = currentColorScheme.textColor
        lastMonthButton.tintColor = currentColorScheme.textColor
        
        //takes away the gap at the top of the collectionView
        self.automaticallyAdjustsScrollViewInsets = false
        
        //formats the collectionView
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        collectionView.backgroundColor = currentColorScheme.secondaryColor
        flowLayout.headerReferenceSize = CGSize(width: self.collectionView.frame.size.width, height: 35)
        //what we had before autolayout; given a frame, expand the view to fit into new frame
    }
    
    
    /*
     Formats the size of each cell
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width / 8.0
        let height = view.bounds.height / 13.5
        return CGSize(width: width, height: height)
    }
    
    
    /*
     Method is called whenever the user taps a valid cell in the calendar. Makes the text field editable and updates the cell's selector background. Pulls up the data from the model and displays it in the text field
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dest = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        notepadTF.isEditable = true       //make the text field selectable and editable to add data to the day
        notepadTF.isSelectable = true
        dest.selectionView.alpha = 0.8
        dateLabel.text = "\(dest.dayRep.month.monthName) \(dest.label.text!), \(dest.dayRep.month.currentYear)"
        
        //if selected, need to toggle in order to get the buttons to trigger correctly
        dest.isSelected = true
        dest.isUserInteractionEnabled = false
        
        selectedDay = dest.dayRep.dayNumValue
        
        notepadTF.text = dest.dayRep.dayText
        notepadTF.font = notepadTF.font?.withSize(18.0)
        
    }
    
    
    /*
     Runs each time a cell is deselected. Makes the text field uneditable and updates the cell selector color. Saves the notepad data to the model.
     */
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let dest = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        dest.isSelected = false
        dest.isUserInteractionEnabled = true
        dest.selectionView.alpha = 0.0
        view.endEditing(true)
        
        if dest.dayRep.getDescription() == todayStringValue {
            dest.selectionView.backgroundColor = currentColorScheme.currentDayColor
            dest.selectionView.alpha = 0.8
        }
        
        //hasDataSelectionViewFormatting
        dest.hasDataSelectionView.layer.cornerRadius = dest.hasDataSelectionView.frame.width / 2.0
        dest.hasDataSelectionView.alpha = 0.0
        if dest.dayRep.containsData() {
            dest.hasDataSelectionView.alpha = 0.8
        }
        
    }
    
    
    /*
     Method that formats each cell in the collectionView (calendar). Each cell gets a corresponding Day object that contains all or the necessary data for that specific day on the calendar.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //formats and fills each cell according to the class CollectionViewCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.isSelected = false
        cell.selectionView.alpha = 0.0
        cell.backgroundColor = currentColorScheme.backGroundColor
        cell.dayRep = monthCollectionArray[(indexPath as NSIndexPath).row]
        if cell.dayRep.dayNumValue == 0 {
            cell.label.text = ""
        } else {
            cell.label.text = String(cell.dayRep.dayNumValue)
        }
        
        //Formats the selectionView circle to show up for selected day
        cell.selectionView.backgroundColor = currentColorScheme.selectedDayColor
        cell.selectionView.layer.cornerRadius = cell.frame.width / 2.0
        cell.label.textColor = currentColorScheme.textColor
        cell.hasDataSelectionView.layer.cornerRadius = cell.hasDataSelectionView.frame.width / 2.0
        cell.hasDataSelectionView.backgroundColor = currentColorScheme.textColor
        
        //If the selectedDay is today, then retain the today color
        if cell.dayRep.getDescription() == todayStringValue {
            cell.selectionView.backgroundColor = currentColorScheme.currentDayColor
            cell.selectionView.alpha = 0.8
        }
        
        //if the label is empty then the user cannot crash the program by pressing it
        if cell.label.text == "" {
            cell.isUserInteractionEnabled = false
        } else {
            cell.isUserInteractionEnabled = true
        }
        
        
        //Small dot above date if the day contains data formatting
        cell.hasDataSelectionView.alpha = 0.0
        if cell.dayRep.containsData() {
            cell.hasDataSelectionView.alpha = 0.8
        }
        
        return cell
    }
    
    
    /*
     Returns the number of items in the collectionView
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return monthCollectionArray.count
    }
    
    
    /*
     Formats the row containing the weekday cells at the top of the calendar (ex. Sun, Mon, Tue ...)
     */
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! WeekdayCollectionReusableView
        view.weekdayCollectionView.delegate = view.self
        view.weekdayCollectionView.dataSource = view.self
        view.backgroundColor = currentColorScheme.backGroundColor
        view.colorScheme = currentColorScheme
        view.weekdayCollectionView.reloadData()
        return view
    }
    
    
    /*
     Tapping outside of the keyboard dismisses it
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    /* 
     Calls lastMonth() helper method when the arrow on the left side of the calendar is tapped
     */
    @IBAction func lastMonthButtonPressed(_ sender: UIButton) {
        lastMonth()
    }
    
    
    /* 
     Calls nextMonth() helper method when the arrow on the right side of the calendar is tapped
     */
    @IBAction func nextMonthButtonPressed(_ sender: UIButton) {
        nextMonth()
    }
    
    
    /* 
     Calls helper method lastMonth when the user swipes the screen right 
     */
    @IBAction func screenSwiped(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .right {
            lastMonth()
        }
        
    }
    
    
    /* 
     Calls helper method nextMonth() when the user swipes the screen left 
     */
    @IBAction func screenSwipedLeft(_ sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .left {
            nextMonth()
        }
        
    }
    
    
    /* 
     Moves the notepadTF up when the keyboard is about to show up. Makes everything else invisible and brings up editing screen
     */
    func keyboardWillShow(_ notif: Notification) {
        let info = (notif as NSNotification).userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        //Alter text to clarify current day
        self.title = "\(selectedMonth.monthName) \(selectedDay), \(selectedYear)"
        dateLabel.text = "Tap to Save"
        
        //disable the month changing buttons
        lastMonthButton.isEnabled = false
        nextMonthButton.isEnabled = false
        lastMonthButton.alpha = 0.0
        nextMonthButton.alpha = 0.0
    
        //Makes sure the keyboard is not already showing
        if !keyboardIsShowingAlready {
            bottomTextFieldConstraint.constant = 20 + h
            topDateLabelConstraint.constant = 8 - h
            collectionView.alpha = 0.0
            keyboardIsShowingAlready = true
        }
        
        collectionViewHeightConstraint.constant = CGFloat(285)

        
    }
    
    
    /* 
     Moved the notepadTF back down when the user dismisses the keyboard. Makes everything reappear and brings back the calendar screen. Also saves the new data inputed if changed to the current day.
     */
    func keyboardWillHide(_ notif: Notification) {
        let info = (notif as NSNotification).userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        //Move notepadTF back down to bring back to calendar screen
        bottomTextFieldConstraint.constant -= h
        topDateLabelConstraint.constant += h
        collectionView.alpha = 1.0
        keyboardIsShowingAlready = false
        
        //Enable the change month buttons again
        lastMonthButton.isEnabled = true
        nextMonthButton.isEnabled = true
        lastMonthButton.alpha = 1.0
        nextMonthButton.alpha = 1.0
        lastMonthButton.titleLabel?.textColor = currentColorScheme.textColor
        nextMonthButton.titleLabel?.textColor = currentColorScheme.textColor
        
        //Reformats text to calendar screen
        self.title = "\(selectedMonth.monthName) \(selectedYear)"
        dateLabel.text = "\(selectedMonth.monthName) \(selectedDay), \(selectedYear)"
        
        let dest = collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems![0]) as! CollectionViewCell
        
        // Saves the data when the cell is deselected
        dest.dayRep.dayText = notepadTF.text ?? ""
        if dest.dayRep.containsData() {
            dayDictionary[dest.dayRep.getDescription()] = dest.dayRep
            saveDateData(dest.dayRep)
        } else {
            dayDictionary.removeValue(forKey: (dest.dayRep?.getDescription())!)
        }
        
        //Resets the size of the calendar depending on how many rows are required
        if(dest.dayRep.month.firstDayInMonth == 5 && dest.dayRep.month.numDaysInMonth == 31) {
            collectionViewHeightConstraint.constant += CGFloat(50)
        }
        else if(dest.dayRep.month.firstDayInMonth == 6 && dest.dayRep.month.numDaysInMonth >= 30) {
            collectionViewHeightConstraint.constant += CGFloat(50)
        }
        
    }
    
    
    /*
     Alters the constraints once again if a different keyboard is chosen (Ex. emoji's etc)
     */
    func keyboardChanged(_ notif: Notification) {
        let info = (notif as NSNotification).userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        bottomTextFieldConstraint.constant = h + 20
        topDateLabelConstraint.constant = 8 - h
    }
    
    
    /*
     Generates the Day array representation of the desired month. Days containing 0's in the beginning of the array represent empty days that are placeholders in order to begin on the desired weekday.
     */
    func generateItemsArray(_ selectedMonthData: Month, selectedYear: Int) -> [Day] {
        
        /*
        PARAMETER           : TYPE      DESCRIPTION
        
        selectedMonthData   : Month     Represents the current selected month to create array for
        selectedYear        : Int       Represents the current selected year to create the array for
        */
        
        var newItemsArray: [Day] = []
        var counter = 1
        let CELL_HEIGHT = 50
        let ORIGINAL_CV_HEIGHT = 285
        
        //Fill first days with empty days to begin on the correct weekday
        if selectedMonthData.firstDayInMonth != 0 {
            for _ in 0 ... selectedMonthData.firstDayInMonth - 1 {
                let emptyDay: Day = Day(month: selectedMonthData, dayNumValue: 0, dayText: "")
                newItemsArray.append(emptyDay)
            }
        }
        
        //Create newDay objects to represent each day of the month. If there is data for a day, the Day object takes that text, else ""
        for _ in selectedMonthData.firstDayInMonth ... (selectedMonthData.numDaysInMonth + selectedMonthData.firstDayInMonth - 1) {
            //gets the current data in the dictionary if it exists
            let currentDayTextValue = dayDictionary[toDateForm(selectedMonthData, dayValue: counter)]?.dayText ?? ""
            let newDay: Day = Day(month: selectedMonthData, dayNumValue: counter, dayText: currentDayTextValue)
            newItemsArray.append(newDay)
            counter += 1
        }
        
        //If the first day is a Friday and there are 30+ days in the month, the collectionView needs an extra row to accommodate for the extra space
        if(selectedMonthData.firstDayInMonth == 6) {
            if(selectedMonthData.numDaysInMonth >= 30) {
                collectionViewHeightConstraint.constant += CGFloat(CELL_HEIGHT)
            }
        }
            
        //If the first day is a Thursday and there are 31 days in the month, the collectionView needs an extra row as well
        else if(selectedMonthData.firstDayInMonth == 5) {
            if(selectedMonthData.numDaysInMonth == 31) {
                collectionViewHeightConstraint.constant += CGFloat(CELL_HEIGHT)
            }
        }
            
        //Else the collectionView has normal height
        else {
            collectionViewHeightConstraint.constant = CGFloat(ORIGINAL_CV_HEIGHT)
        }
        
        return newItemsArray
        
    }
    
    
    /*
     Returns the date in the form (1)M/DD/YYYY from a specified Month object and a day
     */
    func toDateForm(_ month: Month, dayValue: Int) -> String {
        
        return "\(month.monthValue)/\(dayValue)/\(month.currentYear)"
        
    }
    
    
    /*
     Transforms the DaysToSave array into a dictionary of type [String : Day]. In other words, takes the Core Data saved days and integrates them into the current iterations data structure.
     */
    func grabDaysForDictionary() {
        
        for savedDay in previouslySavedDaysArray {
            dayDictionary[savedDay.dateString!] = Day(month: Month(month: getMonthFromString(savedDay.dateString!), year: getYearFromString(savedDay.dateString!)), dayNumValue: getDayFromString(savedDay.dateString!), dayText: savedDay.savedText!)
        }
        
    }
    
    
    /*
     Handles segue to the Settings VC, passing along the currentColorScheme
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsSegue" {
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.colorScheme = currentColorScheme
            settingsViewController.delegate = self
        }
    }
    
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the MM portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
     */
    func getMonthFromString(_ dateString: String) -> Int {
        
        let x = dateString.characters.index(of: "/")
        return Int(dateString.substring(to: x!))!
        
    }
    
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the DD portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
    */
    func getDayFromString(_ dateString: String) -> Int {
        
        let indexOne = dateString.index((dateString.characters.index(of: "/"))!, offsetBy: 1)
        let string = dateString.substring(from: indexOne)
        let secondIndex = string.characters.index(of: "/")
        return Int(String(string.substring(to: secondIndex!)))!
        
    }
    
    
    /*
     takes in a string in the form MM/DD/YYYY and returns the YYYY portiom
     
     Precondition: dateString must be in the form MM/DD/YYYY
     */
    func getYearFromString(_ dateString: String) -> Int {
        
        let year = Int(String(dateString.characters.suffix(4)))
        return year!
        
    }
    
    
    /* 
     Returns the currentColorScheme for the application
     */
    func getCurrentColorScheme() -> ColorScheme {
        return currentColorScheme
    }
    
    
    /*
     Helper function that updates the calendar view with the next month data. Saves the data associated with the current selected day then uses generateItemsArray with the next month and year. Changes title and dateLabel accordingly.
     */
    func nextMonth() {
        
        //Saves data associated with the current day
        if (collectionView.indexPathsForSelectedItems!.count != 0) {
            let cell = collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems![0]) as! CollectionViewCell
            cell.dayRep.dayText = notepadTF.text ?? ""
            if cell.dayRep.containsData() {
                dayDictionary[cell.dayRep.getDescription()] = cell.dayRep
            } else {
                dayDictionary.removeValue(forKey: (cell.dayRep?.getDescription())!)
            }
        }
        
        //Augments month accordingly
        if selectedMonth.monthValue == 12 {
            selectedYear += 1
            selectedMonth = Month(month: 1, year: selectedYear)
            
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue + 1, year: selectedYear)
        }

        //Updates title and generates new array
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        monthCollectionArray = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        notepadTF.isEditable = false
        notepadTF.isSelectable = false
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    /*
     Helper function that updates the calendar view with the last month's data. Saves the data associated with the current day selected and uses generateItemsArray with the last month and corresponding year. Changes title and date label accordingly
     */
    func lastMonth() {
        
        //Saves the data corresponding to the current day selected
        if (collectionView.indexPathsForSelectedItems!.count != 0) {
            let cell = collectionView.cellForItem(at: collectionView.indexPathsForSelectedItems![0]) as! CollectionViewCell
            cell.dayRep.dayText = notepadTF.text ?? ""
            if cell.dayRep.containsData() {
                dayDictionary[cell.dayRep.getDescription()] = cell.dayRep
            } else {
                dayDictionary.removeValue(forKey: (cell.dayRep?.getDescription())!)
            }
        }
        
        //Changes the month value accordingly
        if selectedMonth.monthValue == 1 {
            selectedYear -= 1
            selectedMonth = Month(month: 12, year: selectedYear)
        }
        else {
            selectedMonth = Month(month: selectedMonth.monthValue - 1, year: selectedYear)
        }

        //Changes title and creates new month array
        self.title = selectedMonth.monthName + " " + String(selectedYear)
        monthCollectionArray = generateItemsArray(selectedMonth, selectedYear: selectedYear)
        dateLabel.text = "Select a day"
        notepadTF.text = ""
        notepadTF.isEditable = false
        notepadTF.isSelectable = false
        view.endEditing(true)
        collectionView.reloadData()
    }
    
    
    /*
     Method completing the SettingsUpdatedDelegate with a new corresponding ColorScheme; reloads the collectionView with the new color scheme.
     */
    func settingsHaveBeenUpdated(_ updatedColorScheme: ColorScheme) {
        currentColorScheme = updatedColorScheme
        viewDidAppear(false)
        collectionView.reloadData()
        
    }
    
    
    /*
     Saves the currentColorScheme to NSUserDefaults to be pulled up the next time the user opens the application.
     */
    func applicationDidEnterBackground(_ notif: Notification) {
        UserDefaults.standard.set(currentColorScheme.colorSchemeName, forKey: "ColorSchemeName")
    }
    
    
    /*
     Method that converts a Day object day into a DayToSave NSManagedObject and adds it to the NSManagedObjectContext. Once it's added, the NSManagedObjectContext is saved
     */
    func saveDateData(_ day: Day) {
        
        //add day to the managed object context
        let entity = NSEntityDescription.insertNewObject(forEntityName: "DayToSave", into: managedObjectContext) as! DayToSave
        //set the value for the item
        entity.savedText = day.dayText
        entity.dateString = day.getDescription()
        
        //Save the managed object context back
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to successfully save managedObjectContext")
        }
    }
    
    
    /*
     Method that fetches the [NSManagedObject] from Core Data and converts it to a [DayToSave]
     */
    func fetchDatesFromCoreData() {
        
        // Get the managedObject context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        // Create a fetch request into Core Data
        let fetchRequest = NSFetchRequest<DayToSave>(entityName: "DayToSave")
        
        // Sort the data received by the fetch request from earliest days to latest days
        let sortDescriptor = NSSortDescriptor.init(key: "dateString", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Execute the fetch request
        do {
            
            let fetchedResults = try managedObjectContext.fetch(fetchRequest)
            if fetchedResults.count != 0 {
                self.previouslySavedDaysArray = fetchedResults
            }
        } catch {
            print("Failed to fetch DayToSave array")
        }
        
    }
    
    
    /*
     Method run whenever the application is no longer active. Converts the current iteration of the dayDictionary array to [DayToSave] and adds them to the managedObjectContext. Then saves the managedObjectContext
     */
    func applicationWillResignActive(_ notif: Notification) {

        //Cleans the current managed object context
        deleteAllData("DayToSave")
        
        //adds all days in the dictionary to the managed object context
        for string in dayDictionary.keys {
            let entity = NSEntityDescription.insertNewObject(forEntityName: "DayToSave", into: managedObjectContext) as! DayToSave
            entity.savedText = dayDictionary[string]!.dayText
            entity.dateString = dayDictionary[string]!.getDescription()
            managedObjectContext.insert(entity)
        }
        
        //Saves the managed object context
        do {
            try managedObjectContext.save()
        } catch {
            print("managed object context not properly saved")
        }
    }
    
    
    /*
     Deletes all entries in the Core Data stack in order to prevent repetitive entries. Does this by fetching all of the data and then going through the results and deleting them from the context. 
     */
    func deleteAllData(_ entity: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<DayToSave>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
}

