//
//  UITableView+ThriveChallenge.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    /// Helper method to hide any empty table cells at the bottom of the table
    func hideEmptyCells()
    {
        self.tableFooterView = UIView()
    }
    
    /// Sets up the table to use dynamically sized cells with an estimated height
    func userDynamicCellHeightsWith(estimatedHeight: CGFloat)
    {
        self.rowHeight = UITableViewAutomaticDimension
        self.estimatedRowHeight = estimatedHeight
    }
}
