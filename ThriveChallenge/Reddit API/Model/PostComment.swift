//
//  PostComment.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/2/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit
import SwiftyJSONModel

class PostComment: NSObject, JSONObjectInitializable {

    var uid: String
    var name: String
    var body: String
    var author: String
    var score: Int
    var replies: [String]? = []
    var postDateTimestamp: Int
    
    func numberOfReplies() -> Int {
        if let replies = replies {
            return replies.count
        } else {
            return 0
        }
    }
    
    func postDate() -> Date {
        return Date.init(timeIntervalSince1970: TimeInterval(postDateTimestamp))
    }
    
    func printData() {
        print("Id: \(String(describing: uid))")
        print("Name: \(String(describing: name))")
        print("Body: \(String(describing: body))")
        print("Author: \(String(describing: author))")
        print("Score: \(String(describing: score))")
        print("Reply Comment Ids: \(String(describing: replies))")
        print("Post Date: \(postDate())")
    }
    
    enum PropertyKey: String {
        case uid = "id"
        case name = "name"
        case body = "body"
        case author = "author"
        case score = "score"
        case replies = "reply_comment_ids"
        case postDateTimestamp = "created_utc"
    }
    
    required init(object: JSONObject<PropertyKey>) throws {
        uid = try object.value(for: .uid)
        name = try object.value(for: .name)
        body = try object.value(for: .body)
        author = try object.value(for: .author)
        score = try object.value(for: .score)
        replies = try object.value(for: .replies)
        postDateTimestamp = try object.value(for: .postDateTimestamp)
    }
}
