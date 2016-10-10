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

class SettingsViewController: UIViewController, ColorSchemeChosenDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var changeColorSchemeButton: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!
    
    
    let settingsOptions: [String] = ["Change Color Scheme"]
    var colorScheme: ColorScheme!
    var delegate: SettingsUpdatedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.dataSource = self
        settingsTableView.delegate = self
        
        self.view.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        self.title = "Settings"
    }
    
    
    /*
     Relaod the view with the current ColorScheme
     */
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.backgroundColor = colorScheme.navigationBarColor
        self.view.backgroundColor = colorScheme.backGroundColor
        
        settingsTableView.backgroundColor = colorScheme.backGroundColor

        
        settingsTableView.reloadData()

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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsOptions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "SettingsTVC", for: indexPath) as! SettingsTableViewCell
        cell.settingsLabel.text = settingsOptions[indexPath.row]
        
        cell.settingsLabel.textColor = colorScheme.textColor
        cell.backgroundColor = colorScheme.backGroundColor
        
        return cell
    }
    
    
    

}
