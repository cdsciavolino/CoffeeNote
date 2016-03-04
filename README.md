# SciavolinoCalendarV2.0

**github link: https://github.com/cdsciavolino/SciavolinoCalendarV2.0**

This application is a cross between a calendar and a notepad. It allows you to save information in notepad form for a specific day of the month/year. For example, if you input “Math Homework Due” under Friday, December 4, 2015, the information will be saved to that specific notepad to be pulled up whenever you select that day next.


**TO BE IMPLEMENTED IN THE FUTURE:**
- Move constraints for months that don’t currently fit on the screen
- Better design/appearance/color scheme
- Improve the date label
- Detail view controller (Double tap maybe?)
- Tags for days

**Current Identified Glitches**
- GLITCH: Allow user to open emoji keyboard without glitching the app
- GLITCH: Improve keyboard functionality so the user can move the application to background without glitching the app
- GLITCH: Fix so that the user can quit immediately after editing while still saving the input (in keyboardWillDismiss method?)

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




**Contact**
- Chris Sciavolino
- cds253@cornell.edu