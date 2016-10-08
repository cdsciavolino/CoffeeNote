//
//  SettingsViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 5/29/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

protocol SettingsUpdatedDelegate {
    func settingsHaveBeenUpdated(_ updatedColorScheme: ColorScheme)
}

class SettingsViewController: UIViewController, ColorSchemeChosenDelegate {

    @IBOutlet weak var changeColorSchemeButton: UIButton!
    
    var colorScheme: ColorScheme!
    var delegate: SettingsUpdatedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        self.title = "Settings"
    }
    
    
    /*
     Relaod the view with the current ColorScheme
     */
    override func viewWillAppear(_ animated: Bool) {
        changeColorSchemeButton.titleLabel?.textColor = colorScheme.textColor
        self.navigationController?.navigationBar.backgroundColor = colorScheme.navigationBarColor
        self.view.backgroundColor = colorScheme.backGroundColor
        changeColorSchemeButton.tintColor = colorScheme.textColor


    }

    
    /*
     Function associated with the ColorSchemeChosenDelegate. Alters colorScheme when the user enters the ColorSchemeTableViewController and chooses a new ColorScheme and passes it back to SettingsUpdatedDelegate to make the same changes in that view
     */
    func colorSchemeHasBeenChosen(_ chosenColorScheme: ColorScheme) {
        colorScheme = chosenColorScheme
        viewDidAppear(false)
        if (delegate != nil) {
            delegate?.settingsHaveBeenUpdated(colorScheme)
        }
    }
    

    /*
     Passes the curColorScheme
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeColorSegue" {
            let changeColorViewController = segue.destination as! ColorSchemeEditorTableViewController
            changeColorViewController.curColorScheme = colorScheme
            changeColorViewController.delegate = self
        }
    }

}
