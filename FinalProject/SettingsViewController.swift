//
//  SettingsViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 5/29/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

protocol SettingsUpdatedDeletage {
    func settingsHaveBeenUpdated(updatedColorScheme: ColorScheme)
}

class SettingsViewController: UIViewController, ColorSchemeChosenDelegate {

    @IBOutlet weak var changeColorSchemeButton: UIButton!
    
    var colorScheme: ColorScheme!
    
    var delegate: SettingsUpdatedDeletage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        self.title = "Settings"
        
        // Do and additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        changeColorSchemeButton.titleLabel?.textColor = colorScheme.textColor
        self.navigationController?.navigationBar.backgroundColor = colorScheme.navigationBarColor
        self.view.backgroundColor = colorScheme.backGroundColor
        changeColorSchemeButton.tintColor = colorScheme.textColor


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func colorSchemeHasBeenChosen(chosenColorScheme: ColorScheme) {
        colorScheme = chosenColorScheme
        viewDidAppear(false)
        if (delegate != nil) {
            delegate?.settingsHaveBeenUpdated(colorScheme)
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChangeColorSegue" {
            let changeColorViewController = segue.destinationViewController as! ColorSchemeEditorTableViewController
            changeColorViewController.curColorScheme = colorScheme
            changeColorViewController.delegate = self
        }
    }

}
