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
    
    var WEEKDAYS_LIST = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
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
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //creates unique sizes for each cell
        
        let width = weekdayCollectionView.bounds.width / 9.0
        let height = weekdayCollectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //returns number of items in section AKA how many cells to make
        weekdayCollectionView.backgroundColor = UIColor(red: 0.43922, green: 0.43922, blue: 0.43922, alpha: 0.8)
        
        return WEEKDAYS_LIST.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //inputs data into each cell of the collectionView
        
        let cell = weekdayCollectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! WeekdayCollectionViewCell
        cell.dayLabel.text = String(WEEKDAYS_LIST[indexPath.row])
        cell.dayLabel.textColor = UIColor.whiteColor()
        return cell
    }
}



