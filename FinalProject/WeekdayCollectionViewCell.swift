//
//  WeekdayCollectionViewCell.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/25/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit

class WeekdayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel! // Labeled name of the weekday
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dayLabel.frame = self.bounds //any updates on layout; called whenever layout is changed. Change accordingly
    }
    
}
