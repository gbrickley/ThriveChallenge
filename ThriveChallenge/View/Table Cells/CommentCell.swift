//
//  CommentCell.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/4/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    let horizontalPadding: CGFloat = 15
    let verticalPadding: CGFloat = 10
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialViewSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.numberOfLines = 1
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 1
        label.textAlignment = NSTextAlignment.right
        label.textColor = UIColor.black
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0 // Allow the label to size itself based on the content
        label.textColor = UIColor.black
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - View Setup
    
    func initialViewSetup()
    {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
        containerView.addSubview(authorLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(commentLabel)
        self.contentView.addSubview(containerView)
        updateViewConstraints()
    }
    
    func updateViewConstraints()
    {
        updateContainerConstraints()
        updateAuthorLabelConstraints()
        updateDateLabelConstraints()
        updateCommentLabelConstraints()
    }
    
    func updateContainerConstraints()
    {
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:horizontalPadding).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-horizontalPadding).isActive = true
        containerView.topAnchor.constraint(equalTo:self.contentView.topAnchor, constant:verticalPadding).isActive = true
        containerView.bottomAnchor.constraint(equalTo:self.contentView.bottomAnchor, constant:-verticalPadding).isActive = true
    }
    
    func updateAuthorLabelConstraints()
    {
        let authorWidthRelativeToContainer:CGFloat = 0.6
        authorLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: authorWidthRelativeToContainer).isActive = true
        authorLabel.leadingAnchor.constraint(equalTo:containerView.leadingAnchor).isActive = true
        authorLabel.topAnchor.constraint(equalTo:containerView.topAnchor).isActive = true
    }
    
    func updateDateLabelConstraints()
    {
        dateLabel.leadingAnchor.constraint(equalTo:authorLabel.trailingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo:containerView.trailingAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo:containerView.topAnchor).isActive = true
    }
    
    func updateCommentLabelConstraints()
    {
        let topPadding:CGFloat = 8
        commentLabel.leadingAnchor.constraint(equalTo:containerView.leadingAnchor).isActive = true
        commentLabel.trailingAnchor.constraint(equalTo:containerView.trailingAnchor).isActive = true
        commentLabel.topAnchor.constraint(equalTo:authorLabel.bottomAnchor, constant: topPadding).isActive = true
        commentLabel.bottomAnchor.constraint(equalTo:containerView.bottomAnchor).isActive = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
