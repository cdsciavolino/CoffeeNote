//
//  CollectionViewCell.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/19/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var hasDataSelectionView: UIView!
    
    var dayRep: Day!

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds //any updates on layout; called whenever layout is changed. Change accordingly
    }
}
