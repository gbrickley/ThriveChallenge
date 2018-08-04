//
//  RedditPostViewController.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/2/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit
import MBProgressHUD

class RedditPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// Dictionary keys
    private static let collectionTypeKey = "collectionType"
    private static let postsKey = "posts"
    
    /**
     This array is the main workhorse of the view. Each element in the array is a dictionary with
     two values:
     
     - `collectionTypeKey`: A type of collection @see RedditCollectionType
     - `postsKey`:          An array of RedditPost objects representing the posts we have loaded           for that collection type so far.
     
     New collection types can be added effortlessly by simply adding a new dictionary to this array.
     */
    var posts = [[collectionTypeKey: RedditCollectionType.hot, postsKey: [RedditPost]()],
                 [collectionTypeKey: RedditCollectionType.new, postsKey: [RedditPost]()],
                 [collectionTypeKey: RedditCollectionType.random, postsKey: [RedditPost]()],
                 [collectionTypeKey: RedditCollectionType.top, postsKey: [RedditPost]()]]

    /// The index (in the `posts` array) that the user is currently viewing
    var currentViewingIndex: Int  = 0
    
    /// Handles interaction with the Reddit API
    let redditAPI = RedditAPI()
    
    /// The number of posts we'll grab per API fetch
    let postBatchSize: Int = 15
    
    /// If the Reddit API encountered an error, we'll store the error message here
    var errorMessage: String?
    
    /// The progress indicator we'll use when first loading posts
    var progressHUD: MBProgressHUD?


    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialViewSetup()
        self.title = "Reddit Posts"
        
        loadPostsTable(animated: false)
        
        //runTest();
    }
    
    func initialViewSetup()
    {
        view.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(collectionTypeSegmentedControl)
        view.addSubview(tableView)
    }
    
    override func updateViewConstraints()
    {
        updateCollectionTypeSegmentedControlConstraints()
        updateTableViewConstraints()
        super.updateViewConstraints()
    }
    
    private let postCellReuseIdentifier = "postCell"
    
    lazy var tableView: UITableView = {
        
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.hideEmptyCells()
        tv.userDynamicCellHeightsWith(estimatedHeight: 80)
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = UITableViewCellSeparatorStyle.none
        tv.register(PostCell.self, forCellReuseIdentifier: self.postCellReuseIdentifier)
        return tv
    }()
    
    func updateTableViewConstraints()
    {
        tableView.topAnchor.constraint(equalTo: collectionTypeSegmentedControl.bottomAnchor, constant: 16.0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let posts = postsForCurrentCollectionType()
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellReuseIdentifier, for: indexPath) as! PostCell
        let posts = postsForCurrentCollectionType()
        let post = posts[indexPath.row]

        // A title is required for all posts
        cell.titleLabel.text = post.title
        
        // An author is not required, show as unkonwn if we don't have one
        let author = post.author ?? "Unkown"
        cell.authorLabel.text = "Posted by: \(author)"
        
        // Cell the thumbnail image (asyncronously)
        let aspectRation = post.expectedThumbnailAspectRatio()
        let placeholder = post.thumbnailPlaceholderImage()
        cell.setThumbnailWith(urlString: post.thumbnailUrl, withExpectedAspectRatio: aspectRation, inTableViewOfWidth: UIScreen.main.bounds.width, placeholder: placeholder)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let posts = postsForCurrentCollectionType()
        let post = posts[indexPath.row]
        self.presentCommentsFor(post: post)
    }
    
    func presentCommentsFor(post: RedditPost)
    {
        print("Present commments for post: \(post)")
    }

    
    lazy var collectionTypeSegmentedControl: UISegmentedControl! = {
        let view = UISegmentedControl()
        for (index, object) in posts.enumerated() {
            let type = object[RedditPostViewController.collectionTypeKey] as! RedditCollectionType
            view.insertSegment(withTitle: type.displayName().capitalized, at: index, animated: false)
        }
        view.selectedSegmentIndex = currentViewingIndex
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(collectionTypeDidChange(_:)), for: .valueChanged)
        return view
    }()
    
    
    @objc func collectionTypeDidChange(_ segmentedControl: UISegmentedControl)
    {
        currentViewingIndex = segmentedControl.selectedSegmentIndex
        loadPostsTable(animated: true)
    }
    
    func updateCollectionTypeSegmentedControlConstraints()
    {
        NSLayoutConstraint(item: collectionTypeSegmentedControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: collectionTypeSegmentedControl, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.9, constant: 0.0).isActive = true
        
        collectionTypeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
    }
    
    func loadPostsTable(animated: Bool)
    {
        print("Present view for collection type: \(currentViewingIndex)")
        self.hidePostActivityIndicator()
        let posts = postsForCurrentCollectionType()
        
        var fadeOutInterval: TimeInterval = 0
        var fadeInInterval: TimeInterval = 0
        if (animated) {
            fadeOutInterval = 0.1
            fadeInInterval = 0.1
        }

        tableView.fadeOut(fadeOutInterval, delay: 0, completion: { finished in
            self.tableView.reloadData()
            self.tableView.fadeIn(fadeInInterval, delay: 0, completion: { finished in
                // Once we're finished displaying the correct table, see if we need to load posts
                if (posts.count == 0) {
                    self.loadNextPageOfPosts()
                }
            })
        })
    }
    
    func loadNextPageOfPosts()
    {
        let postIndex = currentViewingIndex
        let collectionType = currentCollectionType()
        var loadedPosts = postsForCurrentCollectionType()
        let after = lastLoadedPostNameInCurrentCollectionType()
        
        // If we don't have any posts loaded yet, show an activity indicator
        if (loadedPosts.count == 0) {
            showPostActivityIndicatorFor(collectionType: collectionType)
        }
        
        redditAPI.postsFor(collectionType: collectionType, after: after, limit: postBatchSize, completion: { result in
            
            switch result {
                
                case .success(let newPosts):
                    // Add the new posts and then reload the table view
                    print("New posts loaded: \(newPosts)")
                    loadedPosts.append(contentsOf: newPosts as! Array<RedditPost>)
                    self.posts[postIndex][RedditPostViewController.postsKey] = loadedPosts

                case .error(let code, let friendlyMessage, let cause):
                    // Save a reference to this error message in case we need to show to the user
                    print("Error [\(code)]: \(friendlyMessage) - Cause: \(cause)")
                    self.errorMessage = friendlyMessage
            }
            
            // Reload the table view so any new results are shown
            print(self.posts)
            self.tableView.reloadData()
            self.hidePostActivityIndicator()
        })
    }
    
    
    // MARK: - Activity Indicator
    
    private func showPostActivityIndicatorFor(collectionType: RedditCollectionType)
    {
        //tableView.isHidden = true
        progressHUD = MBProgressHUD.showAdded(to: tableView, animated: true)
        progressHUD?.label.text = "Loading \(collectionType.displayName()) posts..."
    }
    
    private func hidePostActivityIndicator()
    {
        progressHUD?.hide(animated: true)
        //self.tableView.hidden = FALSE;
    }
    
    func runTest()
    {
        let redditAPI = RedditAPI()
        
        redditAPI.commentsForPostWithId(postId: "945geo", after: "t1_e3igs29", limit: 10, completion: { result in
            
            switch result {
            case .success(let comments):
                print("Retrieved comments: \(comments)");
                for comments in comments as! Array<PostComment> {
                    print("[\(comments.name)] \(comments.body)")
                    //comments.printData()
                }
                
            case .error(let code, let friendlyMessage, let cause):
                print("Error [\(code)]: \(friendlyMessage) - Cause: \(cause)")
            }
        })

        /*
        redditAPI.postsFor(collectionType: .hot, after: "t3_945n28", limit: 3, completion: { result in

            switch result {
            case .success(let posts):
                // handle successful data response here
                print("Retrieved posts: \(posts)");
                
                for post in posts as! Array<RedditPost> {
                    post.printData()
                }
                
            case .error(let code, let friendlyMessage, let cause):
                print("Error [\(code)]: \(friendlyMessage) - Cause: \(cause)")
            }
        })*/
    }

    // MARK - Helper Methods
    
    private func currentCollectionType() -> RedditCollectionType
    {
        return posts[currentViewingIndex][RedditPostViewController.collectionTypeKey] as! RedditCollectionType
    }
    
    private func postsForCurrentCollectionType() -> Array<RedditPost>
    {
        return posts[currentViewingIndex][RedditPostViewController.postsKey] as! Array<RedditPost>
    }
    
    private func lastLoadedPostNameInCurrentCollectionType() -> String?
    {
        if let lastPost = postsForCurrentCollectionType().last {
            return lastPost.name
        } else {
            return nil
        }
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
