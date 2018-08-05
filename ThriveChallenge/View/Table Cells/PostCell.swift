//
//  PostCell.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/3/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    /// We hold a reference to the image height constraint in case we need to change it later
    var thumbnailImageHeightConstraint : NSLayoutConstraint?
    
    /// Padding for cell elements
    let horizontalPadding: CGFloat = 10
    let verticalPadding: CGFloat = 10
    let labelHorizontalPadding: CGFloat = 10
    
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialViewSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Public Methods
    
    /**
     Sets the thumbnail image using a remote url.
     
     - Parameter urlString: The url, as a string, where the image is located.
     - Parameter aspectRatio: The expected aspect ratio of the image at the given url.
     - Parameter tableViewWidth: The width of the table view this cell is contained within.
     - Parameter placeholder: A placeholder image to display when the real image downloads.
     */
    public func setThumbnailWith(urlString: String?, withExpectedAspectRatio aspectRatio: CGFloat, inTableViewOfWidth tableViewWidth: CGFloat, placeholder: UIImage)
    {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            thumbnailImageView.image = placeholder
            setThumbnailAspectRatio(aspectRatio: placeholder.aspectRatio(), forTableViewOfWidth: tableViewWidth)
            return
        }
        
        // Setup the expected aspect ratio and start loading the image
        setThumbnailAspectRatio(aspectRatio: aspectRatio, forTableViewOfWidth: tableViewWidth)
        
        // Load the image asyncronously
        showPostActivityIndicator()
        thumbnailImageView.setImageFrom(url: url, placholder: placeholder, completion: { success in
            self.hidePostActivityIndicator()
        })
    }
    

    // MARK: - UI Elements
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0 // Set lines to 0 so we can dynamically size the label
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 1 // We'll restrict the author label to 1 line always
        label.textColor =  UIColor.black
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let thumbnailImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage.init(named: "thumbnail-placeholder")
        return img
    }()
}


// MARK: - View Setup
private extension PostCell {
    
    func initialViewSetup()
    {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.backgroundColor = UIColor.clear
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(thumbnailImageView)
        self.contentView.addSubview(containerView)
        updateViewConstraints()
    }
    
    func updateViewConstraints()
    {
        updateContainerConstraints()
        updateTitleConstraints()
        updateAuthorConstraints()
        updateThumbnailImageConstraints()
    }
    
    func updateContainerConstraints()
    {
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:horizontalPadding).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-horizontalPadding).isActive = true
        containerView.topAnchor.constraint(equalTo:self.contentView.topAnchor, constant:0).isActive = true
        containerView.bottomAnchor.constraint(equalTo:self.contentView.bottomAnchor, constant:-verticalPadding).isActive = true
    }
    
    func updateTitleConstraints()
    {
        titleLabel.leadingAnchor.constraint(equalTo:containerView.leadingAnchor, constant:labelHorizontalPadding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo:containerView.trailingAnchor, constant:-labelHorizontalPadding).isActive = true
        titleLabel.topAnchor.constraint(equalTo:containerView.topAnchor, constant:10).isActive = true
    }
    
    func updateAuthorConstraints()
    {
        authorLabel.leadingAnchor.constraint(equalTo:containerView.leadingAnchor, constant:labelHorizontalPadding).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo:containerView.trailingAnchor, constant:-labelHorizontalPadding).isActive = true
        authorLabel.topAnchor.constraint(equalTo:titleLabel.bottomAnchor, constant: 6).isActive = true
    }
    
    func updateThumbnailImageConstraints()
    {
        thumbnailImageView.leadingAnchor.constraint(equalTo:containerView.leadingAnchor).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo:containerView.trailingAnchor).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo:authorLabel.bottomAnchor, constant: 10).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo:containerView.bottomAnchor).isActive = true
        
        // We'll adjust based on the post we bind to the cell
        setThumbnailHeight(height: 100)
    }
    
    func setThumbnailAspectRatio(aspectRatio: CGFloat, forTableViewOfWidth: CGFloat)
    {
        let height = (forTableViewOfWidth - (horizontalPadding*2)) / CGFloat(aspectRatio)
        setThumbnailHeight(height: height)
    }
    
    func setThumbnailHeight(height: CGFloat)
    {
        if (thumbnailImageHeightConstraint != nil) {
            thumbnailImageHeightConstraint?.constant = height
        } else {
            thumbnailImageHeightConstraint = thumbnailImageView.heightAnchor.constraint(equalToConstant:height)
        }
        
        thumbnailImageHeightConstraint?.isActive = true
    }
}


// MARK: - Private Methods
private extension PostCell {
    
    // MARK: Activity Indicator
    
    func showPostActivityIndicator()
    {
        // TODO: ADD IF WE DECIDE WE WANT THIS
    }
    
    func hidePostActivityIndicator()
    {
        // TODO: ADD IF WE DECIDE WE WANT THIS
    }
    
}
