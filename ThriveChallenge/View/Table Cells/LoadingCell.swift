//
//  LoadingCell.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit

class LoadingCell: UITableViewCell {

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
        let verticalPadding: CGFloat = 40
        activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo:self.contentView.topAnchor, constant:verticalPadding).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo:self.contentView.bottomAnchor, constant:-verticalPadding).isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
