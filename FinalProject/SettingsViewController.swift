//
//  SettingsViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 5/29/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var changeColorSchemeButton: UIButton!
    
    var colorScheme: ColorScheme!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        self.title = "Settings"

        // Do and additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        changeColorSchemeButton.titleLabel?.textColor = colorScheme.textColor
        self.navigationController?.navigationBar.backgroundColor = colorScheme.navigationBarColor
        self.view.backgroundColor = colorScheme.backGroundColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ChangeColorSegue" {
            let changeColorViewController = segue.destinationViewController as! ColorSchemeEditorTableViewController
            changeColorViewController.curColorScheme = colorScheme
        }
    }

}
