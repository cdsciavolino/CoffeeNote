//
//  SettingsTableViewCell.swift
//  MoonNote
//
//  Created by Chris Sciavolino on 10/10/16.
//  Copyright © 2016 Chris Sciavolino. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
