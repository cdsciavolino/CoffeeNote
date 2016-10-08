//
//  ColorScheme.swift
//  Noted
//
//  Created by Chris Sciavolino on 5/30/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

class ColorScheme: NSObject {
    
    var colorSchemeName: String         // Name associated with the ColorScheme
    var backGroundColor: UIColor        // UIColor for the background of each view
    var secondaryColor: UIColor         // UIColor for the secondary view on top of the background view
    var textColor: UIColor              // UIColor for the text
    var navigationBarColor: UIColor     // UIColor for the navigation bar
    var currentDayColor: UIColor        // UIColor for the selectionView on the current day on the calendar view
    var selectedDayColor: UIColor       // UIColor for the selectionView on the selected day on the calendar view
        
    override init() {
        backGroundColor = UIColor.black
        textColor = UIColor.black
        secondaryColor = UIColor.black
        navigationBarColor = UIColor.black
        currentDayColor = UIColor.black
        selectedDayColor = UIColor.black
        colorSchemeName = ""
    }
    
    
    init(backCol: UIColor, secCol: UIColor, texCol: UIColor, navCol: UIColor, curCol: UIColor, selCol: UIColor, name: String) {
        backGroundColor = backCol
        secondaryColor = secCol
        textColor = texCol
        navigationBarColor = navCol
        currentDayColor = curCol
        selectedDayColor = selCol
        colorSchemeName = name
    }
    
    
    static func darkGreyScheme() -> ColorScheme {
        return ColorScheme(
            backCol: UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 1.0),
            secCol: UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0),
            texCol: UIColor.white,
            navCol: UIColor.black,
            curCol: UIColor(red: 0.54117645, green: 0.8627451, blue: 0.8627451, alpha: 1.0),
            selCol: UIColor.orange,
            name: "Midnight Grey")
    }
    
    
    static func darkBlueScheme() -> ColorScheme {
        return ColorScheme(
            backCol: UIColor(red: 35/255.0, green: 72/255.0, blue: 108/255.0, alpha: 1.0),
            secCol: UIColor(red: 63/255.0, green: 118/255.0, blue: 150/255.0, alpha: 1.0),
            texCol: UIColor.white,
            navCol: UIColor(red: 3/255.0, green: 30/255.0, blue: 55/255.0, alpha: 1.0),
            curCol: UIColor(red: 15/255.0, green: 50/255.0, blue: 83/255.0, alpha: 1.0),
            selCol: UIColor(red: 93/255.0, green: 10/255.0, blue: 75/255.0, alpha: 1.0),
            name: "Ocean Blue")
    }
    
}
