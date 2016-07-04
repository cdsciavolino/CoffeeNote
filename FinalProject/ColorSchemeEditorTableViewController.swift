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

    let colorSchemeArray: [ColorScheme] = [ColorScheme.darkGreyScheme(), ColorScheme.darkBlueScheme()]
    
    var curColorScheme: ColorScheme!
    
    var delegate: ColorSchemeChosenDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.view.backgroundColor = curColorScheme.backGroundColor
        self.navigationController?.navigationBar.backgroundColor = curColorScheme.navigationBarColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return colorSchemeArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ColorCell", forIndexPath: indexPath) as! ColorTableViewCell

        let cellColor = colorSchemeArray[indexPath.row]
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
        
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        curColorScheme = colorSchemeArray[indexPath.row]
        viewWillAppear(false)
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        if (delegate != nil) {
            delegate?.colorSchemeHasBeenChosen(curColorScheme)
        }
    }

}
