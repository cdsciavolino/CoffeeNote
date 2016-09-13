//
//  ColorSchemeEditorTableViewController.swift
//  Noted
//
//  Created by Chris Sciavolino on 6/4/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

protocol ColorSchemeChosenDelegate {
    func colorSchemeHasBeenChosen(chosenColorScheme: ColorScheme)
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
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = curColorScheme.backGroundColor
        self.navigationController?.navigationBar.backgroundColor = curColorScheme.navigationBarColor
    }
    

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return COLOR_SCHEME_ARRAY.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorCell", forIndexPath: indexPath) as! ColorTableViewCell

        let cellColor = COLOR_SCHEME_ARRAY[indexPath.row]
        cell.colorLabel.text = cellColor.colorSchemeName
        cell.backgroundColor = cellColor.backGroundColor
        cell.colorLabel.textColor = cellColor.textColor
        cell.selectedView.layer.cornerRadius = cell.selectedView.frame.width / 2.0
        cell.selectedView.alpha = 1.0
        
        if (cellColor.colorSchemeName == curColorScheme.colorSchemeName) {
            cell.selectedView.alpha = 0.0
        }
        
        
        return cell
    }
        
    
    /*
     Reloads the view with the new chosen ColorScheme
     */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        curColorScheme = COLOR_SCHEME_ARRAY[indexPath.row]
        viewWillAppear(false)
        tableView.reloadData()
    }
    
    
    /*
     Passes back the selected colorScheme to the SettingsViewController when the user taps the back button
     */
    override func viewWillDisappear(animated: Bool) {
        if (delegate != nil) {
            delegate?.colorSchemeHasBeenChosen(curColorScheme)
        }
    }

}
