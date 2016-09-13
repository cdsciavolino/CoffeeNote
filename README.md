# SciavolinoCalendarV2.0

**github link: https://github.com/cdsciavolino/SciavolinoCalendarV2.0**

This application is a cross between a calendar and a notepad. It allows you to save information in notepad form for a specific day of the month/year. For example, if you input “Math Homework Due” under Friday, December 4, 2015, the information will be saved to that specific notepad to be pulled up whenever you select that day next.


**TO BE IMPLEMENTED IN THE FUTURE:**
- Better design/appearance/color scheme
- Detail view controller
- Tags for days
- Choice of integrating iCloud storage to maintain over multiple devices
- Small rectangles that show color of each scheme in ColorTableViewCells
- Setting option to delete data from longer than 3(x?) months ago etc
- Ability to tap date and go to any date valid on ViewController screen

**Current Identified Glitches**
- GLITCH: Month buttons on either side of calendar change back to white when data is edited (assuming different color scheme
- GLITCH: Does not format correctly on other models of phone

**What I did**
- Implemented a calendar view with correctly numbered days/correctly set days of the week
- Created a dictionary to hold each date’s data with keys corresponding to the day selected
- Implemented nextMonth and lastMonth buttons to change between months without forgetting data from the previous month
- Move both dateLabel and notepadTF up with the keyboard when tapped
- Swipe functionality
- CoreData so the data can be saved when the application is closed 
- Small icon that shows if a day contains information on a specified date

**Fixed Glitches**
- FIXED: Fix months that have days that don’t fit in the current items array (move constraints or make scrollable)
- FIXED: When user taps same date after editing, deletes the data that was inputed. 
- FIXED: Improve CoreData object models to use less memory / space
- FIXED: Allow user to open emoji keyboard without glitching the app
- FIXED: Improve keyboard functionality so the user can move the application to background without glitching the app
- FIXED: Fix so that the user can quit immediately after editing while still saving the input (in keyboardWillDismiss method?)
- FIXED: Currently does not delete empty day objects in NSManagedObjectContext
- FIXED: Move constraints for months that don’t currently fit on the screen


**Contact**
- Chris Sciavolino
- cds253@cornell.edu