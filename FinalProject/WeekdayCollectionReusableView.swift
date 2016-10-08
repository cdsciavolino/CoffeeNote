//
//  WeekdayCollectionReusableView.swift
//  FinalProject
//
//  Created by Chris Sciavolino on 11/23/15.
//  Copyright © 2015 Chris Sciavolino. All rights reserved.
//

import UIKit

class WeekdayCollectionReusableView: UICollectionReusableView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var weekdayCollectionView: UICollectionView!
    
    var colorScheme: ColorScheme!
    
    let WEEKDAYS_LIST = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    lazy var flowLayout: UICollectionViewFlowLayout = {
        
        //standard way of flipping phone sideways
        
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        flow.minimumInteritemSpacing = 0.0
        flow.minimumLineSpacing = 1.0
        flow.itemSize = CGSize(width: 300, height: 300)
        flow.sectionInset.top = 0.0
        return flow
    }()
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        //creates unique sizes for each cell
        
        let width = weekdayCollectionView.bounds.width / 7.0
        let height = weekdayCollectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //returns number of items in section AKA how many cells to make
        weekdayCollectionView.backgroundColor = colorScheme.backGroundColor
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = colorScheme.secondaryColor.cgColor
        border.frame = CGRect(x: 0, y: weekdayCollectionView.frame.size.height - width, width:  weekdayCollectionView.frame.size.width, height: weekdayCollectionView.frame.size.height)
        
        border.borderWidth = width
        weekdayCollectionView.layer.addSublayer(border)
        weekdayCollectionView.layer.masksToBounds = true
        
        return WEEKDAYS_LIST.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //inputs data into each cell of the collectionView
        
        let cell = weekdayCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! WeekdayCollectionViewCell
        cell.dayLabel.text = String(WEEKDAYS_LIST[(indexPath as NSIndexPath).row])
        cell.dayLabel.textColor = colorScheme.textColor
        cell.backgroundColor = colorScheme.backGroundColor
        return cell
    }
}



