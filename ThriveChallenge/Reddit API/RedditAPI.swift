//
//  RedditAPI.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/2/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON


enum RedditCollectionType: String {
    
    case hot    = "hot"
    case new    = "new"
    case random = "random"
    case top    = "top"
    
    /// A user friendly name describing the collection type
    func displayName() -> String {
        return self.rawValue
    }
}

enum Result<T> {
    case success(T)
    case error(code: Int, friendlyDescription: String, cause: String)
}


// MARK: - Public Methods
class RedditAPI: NSObject {
    
    /// Block used to return fetched data
    typealias redditCompletionBlock = (Result<Any>) -> Void
    
    /**
     Retreieves redit posts, ordered by post date with the most recent first.
     
     - Parameter collectionType: @see RedditCollectionType enum for possible values.
     - Parameter after: String: Optionally pass the name of a post to fetch results after.
     - Parameter limit: The max number of posts to return, defaults to 20.
     - Parameter redditCompletionBlock: The block to be executed when the request finishes. If the request is successful, an array of `RedditPost` objects will be returned.
     */
    public func postsFor(collectionType: RedditCollectionType, after afterPostName: String?, limit: Int = 20, completion: @escaping redditCompletionBlock )
    {
        guard let url = requestURLForPostOf(collectionType: collectionType) else {
            let descrip = "Could not retrieve Reddit data."
            let cause = "Invalid API request url"
            completion(Result.error(code: 450, friendlyDescription: descrip, cause: cause))
            return
        }
        
        var params: Parameters = ["limit": limit]
        if let after = afterPostName {
            params["after"] = after
        }
        
        //print("[Reddit API]: Request URL: \(url)")
        //print("[Reddit API]: Params: \(params)")
        
        Alamofire.request(url, parameters: params).validate().responseJSON { response in
            
            switch response.result {
                
            case .failure(let error):
                completion(Result.error(code: 451, friendlyDescription: error.localizedDescription, cause: "HTTP GET request error"))
                return;
            
            case .success(let data):
                let json = JSON(data)
                //print(json)
                guard let postsAsJSON = json["data"]["children"].array else {
                    let descrip = "Could not retrieve Reddit data."
                    let cause = "Malformed JSON data returned"
                    completion(Result.error(code: 453, friendlyDescription: descrip, cause: cause))
                    return
                }
                
                var allPosts: [RedditPost] = []
                for postAsJSON in postsAsJSON {
                    do {
                        var data = postAsJSON["data"]
                        data["postThumbnail"] = self.optimumThumbnailFromPostDate(data: data)
                        print(data["postThumbnail"])
                        let post = try RedditPost(json: data)
                        allPosts.append(post)
                    } catch let error {
                        print(error)
                    }
                }
                
                completion(Result.success(allPosts))
            }
        }
    }
    
    /**
     Retreieves comments for a post, ordered by post date with the most recent first.
     
     - Parameter postId: The id of the post to retrieve comments for.
     - Parameter after: Optionally pass the name of a comment to fetch results after.
     - Parameter limit: The max number of comments to return, defaults to 20.
     - Parameter redditCompletionBlock: The block to be executed when the request finishes. If the request is successful, an array of `PostComment` objects will be returned.
     */
     public func commentsForPostWithId(postId: String, after afterCommentName: String?, limit: Int = 20, completion: @escaping redditCompletionBlock )
    {
        guard let url = requestURLForCommentsOnPostWithId(postId: postId) else {
            let friendlyDescription = "Could not retrieve Reddit data."
            let cause = "Invalid API request url"
            completion(Result.error(code: 450, friendlyDescription: friendlyDescription, cause: cause))
            return
        }
        
        var params: Parameters = ["limit": limit, "include_facets": false]
        if let after = afterCommentName {
            params["after"] = after
        }
        
        print("[Comment Request]: Request URL: \(url)")
        print("[Comment Request]: Params: \(params)")
        
        Alamofire.request(url, parameters: params).validate().responseJSON { response in
            
            switch response.result {
                
            case .failure(let error):
                completion(Result.error(code: 451, friendlyDescription: error.localizedDescription, cause: "HTTP GET request error"))
                return;
                
            case .success(let data):
                let json = JSON(data)
                
                guard let commentsAsJSON = json[1]["data"]["children"].array else {
                    let descrip = "Could not retrieve Reddit data."
                    let cause = "Malformed JSON data returned"
                    completion(Result.error(code: 453, friendlyDescription: descrip, cause: cause))
                    return
                }
                
                var allComments: [PostComment] = []
                for commentAsJSON in commentsAsJSON {
                    do {
                        var data = commentAsJSON["data"]
                        data["reply_comment_ids"] = data["replies"]["data"]["children"][0]["data"]["children"]
                        let comment = try PostComment(json: data)
                        allComments.append(comment)
                    } catch let error {
                        print(error)
                    }
                }
                
                completion(Result.success(allComments))
            }
        }
    }
}


// MARK: - Private Methods
private extension RedditAPI {
    
    static let apiBaseUrl = "https://www.reddit.com/r"
    
    func requestURLForPostOf(collectionType: RedditCollectionType) -> URL?
    {
        let str = "\(RedditAPI.apiBaseUrl)/all/\(collectionType.rawValue)/.json"
        return urlFromRaw(str:str)
    }
    
    func requestURLForCommentsOnPostWithId(postId: String) -> URL?
    {
        let str = "\(RedditAPI.apiBaseUrl)/comments/\(postId)/.json"
        return urlFromRaw(str:str)
    }
    
    func urlFromRaw(str: String) -> URL?
    {
        guard let enc = str.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed),
            let url = URL.init(string: enc) else {
                return nil
        }
        return url
    }
    
    private func optimumThumbnailFromPostDate(data: JSON) -> JSON
    {
        var thumbnail:[String: Any] = [:]
        thumbnail["url"] = data["thumbnail"]
        thumbnail["width"] = data["thumbnail_width"]
        thumbnail["height"] = data["thumbnail_height"]
        
        // If we don't have any other options, return the thumbnail
        guard let images = data["preview"]["images"].array else {
            return JSON(thumbnail)
        }
        
        let widthPreferences = [640, 960, 1020, 320]
        let buffer: Int = 160
        
        for widthPreference in widthPreferences {
            for image in images {
                
                // TODO: FOR NOW, WE'LL EXCLUDE GIFS.  CAN REMOVE ONCE GIF HANDLING IS ADDED
                if let width = image["source"]["width"].int, width > widthPreference - buffer, width < widthPreference + buffer, let url = image["source"]["url"].url, !url.isGif() {
                    
                    thumbnail["url"] = image["source"]["url"]
                    thumbnail["width"] = width
                    thumbnail["height"] = image["source"]["height"]
                    return JSON(thumbnail)
                }
            }
        }
        
        return JSON(thumbnail)
    }
}
