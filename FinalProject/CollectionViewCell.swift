//
//  CollectionViewCell.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/19/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!                  // Number of day
    @IBOutlet weak var selectionView: UIView!           // Circle view showing whether day is selected
    @IBOutlet weak var hasDataSelectionView: UIView!    // Boolean value whether day has data or not
    
    var dayRep: Day!    // Day data of corresponding day on calendar

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds //any updates on layout; called whenever layout is changed. Change accordingly
    }
}
