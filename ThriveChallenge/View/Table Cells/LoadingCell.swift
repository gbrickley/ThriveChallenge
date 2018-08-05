//
//  LoadingCell.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {
    
    var height: CGFloat = 40
    var topPaddingConstraint : NSLayoutConstraint?
    var bottomPaddingConstraint : NSLayoutConstraint?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    func initialViewSetup()
    {
        // Hide the cell separator for the loading view
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, UIScreen.main.bounds.width)
        self.isUserInteractionEnabled = false
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(activityIndicator)
        updateViewConstraints()
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        ind.translatesAutoresizingMaskIntoConstraints = false
        return ind
    }()
    
    func updateViewConstraints()
    {
        updateActivityIndicatorConstraints()
    }
    
    func updateActivityIndicatorConstraints()
    {
        activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        set(height: self.height)
    }
    
    func set(height: CGFloat)
    {
        self.height = height
        let indHeight = activityIndicator.bounds.size.height
        let verticalPadding = (height - indHeight) / 2
        
        if (topPaddingConstraint != nil) {
            topPaddingConstraint?.constant = verticalPadding
        } else {
            topPaddingConstraint = activityIndicator.topAnchor.constraint(equalTo:self.contentView.topAnchor, constant:verticalPadding)
        }
        
        if (bottomPaddingConstraint != nil) {
            bottomPaddingConstraint?.constant = -verticalPadding
        } else {
            bottomPaddingConstraint = activityIndicator.bottomAnchor.constraint(equalTo:self.contentView.bottomAnchor, constant:-verticalPadding)
        }
        
        topPaddingConstraint?.isActive = true
        bottomPaddingConstraint?.isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
