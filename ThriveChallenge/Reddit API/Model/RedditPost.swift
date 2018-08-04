//
//  RedditPost.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/2/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit
import SwiftyJSONModel

class RedditPost: NSObject, JSONObjectInitializable {
    
    var uid: String
    var name: String
    var title: String
    var author: String?
    var thumbnailUrl: String?
    var thumbnailWidth: Int?
    var thumbnailHeight: Int?
    
    public func expectedThumbnailAspectRatio() -> CGFloat
    {
        if let width = thumbnailWidth, let height = thumbnailHeight {
            return CGFloat(width) / CGFloat(height)
        } else {
            return thumbnailPlaceholderImage().aspectRatio()
        }
    }
    
    public func thumbnailPlaceholderImage() -> UIImage
    {
        return UIImage.init(named: "thumbnail-placeholder")!
    }
    
    enum PropertyKey: String {
        case uid = "id"
        case name = "name"
        case title = "title"
        case author = "author"
        case thumbnail = "postThumbnail"
        case thumbnailUrl = "url"
        case thumbnailWidth = "width"
        case thumbnailHeight = "height"
    }
    
    required init(object: JSONObject<PropertyKey>) throws {
        uid = try object.value(for: .uid)
        name = try object.value(for: .name)
        title = try object.value(for: .title)
        author = try object.value(for: .author)
        thumbnailUrl = try object.value(for: .thumbnail, .thumbnailUrl)
        thumbnailWidth = try object.value(for: .thumbnail, .thumbnailWidth)
        thumbnailHeight = try object.value(for: .thumbnail, .thumbnailHeight)
    }

    func printData() {
        print("Id: \(String(describing: uid))")
        print("Name: \(String(describing: name))")
        print("Author: \(String(describing: author))")
        print("Title: \(String(describing: title))")
        print("Thumbnail Url: \(String(describing: thumbnailUrl))")
        print("Thumbnail Width: \(String(describing: thumbnailWidth))")
        print("Thumbnail Height: \(String(describing: thumbnailHeight))")
        print("Aspect Ratio: \(self.expectedThumbnailAspectRatio())")
    }

}
