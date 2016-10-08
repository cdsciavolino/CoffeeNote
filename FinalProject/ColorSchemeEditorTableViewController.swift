//
//  ColorSchemeEditorTableViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 6/4/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

protocol ColorSchemeChosenDelegate {
    func colorSchemeHasBeenChosen(_ chosenColorScheme: ColorScheme)
}

class ColorSchemeEditorTableViewController: UITableViewController {

    let COLOR_SCHEME_ARRAY: [ColorScheme] = [ColorScheme.darkGreyScheme(), ColorScheme.darkBlueScheme()]
    
    var curColorScheme: ColorScheme!
    
    var delegate: ColorSchemeChosenDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    /*
     Used to reload the colors of the view with the new curColorScheme
     */
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = curColorScheme.backGroundColor
        self.navigationController?.navigationBar.backgroundColor = curColorScheme.navigationBarColor
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return COLOR_SCHEME_ARRAY.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorCell", for: indexPath) as! ColorTableViewCell

        let cellColor = COLOR_SCHEME_ARRAY[(indexPath as NSIndexPath).row]
        cell.colorLabel.text = cellColor.colorSchemeName
        cell.backgroundColor = cellColor.backGroundColor
        cell.colorLabel.textColor = cellColor.textColor
        
        return cell
    }
        
    
    /*
     Reloads the view with the new chosen ColorScheme
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        curColorScheme = COLOR_SCHEME_ARRAY[(indexPath as NSIndexPath).row]
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    /*
     Passes back the selected colorScheme to the SettingsViewController when the user taps the back button
     */
    override func viewWillDisappear(_ animated: Bool) {
        if (delegate != nil) {
            delegate?.colorSchemeHasBeenChosen(curColorScheme)
        }
    }

}
