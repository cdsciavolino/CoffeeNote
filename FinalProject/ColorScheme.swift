//
//  ColorScheme.swift
//  Noted
//
//  Created by Chris Sciavolino on 5/30/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

class ColorScheme: NSObject {
    
    var colorSchemeName: String
    var backGroundColor: UIColor
    var secondaryColor: UIColor
    var textColor: UIColor
    var navigationBarColor: UIColor
    var currentDayColor: UIColor
    var selectedDayColor: UIColor
    
    override init() {
        backGroundColor = UIColor.blackColor()
        textColor = UIColor.blackColor()
        secondaryColor = UIColor.blackColor()
        navigationBarColor = UIColor.blackColor()
        currentDayColor = UIColor.blackColor()
        selectedDayColor = UIColor.blackColor()
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
            backCol: UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8),
            secCol: UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8),
            texCol: UIColor.whiteColor(),
            navCol: UIColor.blackColor(),
            curCol: UIColor(red: 0.54117645, green: 0.8627451, blue: 0.8627451, alpha: 1.0),
            selCol: UIColor.orangeColor(),
            name: "Midnight Grey")
    }
    
    static func darkBlueScheme() -> ColorScheme {
        return ColorScheme(
            backCol: UIColor(red: 35/255.0, green: 72/255.0, blue: 108/255.0, alpha: 1.0),
            secCol: UIColor(red: 43/255.0, green: 81/255.0, blue: 117/255.0, alpha: 0.8),
            texCol: UIColor.whiteColor(),
            navCol: UIColor(red: 3/255.0, green: 30/255.0, blue: 55/255.0, alpha: 1.0),
            curCol: UIColor(red: 15/255.0, green: 50/255.0, blue: 83/255.0, alpha: 1.0),
            selCol: UIColor(red: 93/255.0, green: 10/255.0, blue: 75/255.0, alpha: 1.0),
            name: "Ocean Blue")
    }
    
    // secCol: UIColor(red: 57/255.0, green: 94/255.0, blue: 130/255.0, alpha: 1.0)

}
