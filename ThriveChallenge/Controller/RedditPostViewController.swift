//
//  RedditPostViewController.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/2/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit
import MBProgressHUD
import EmptyDataSet_Swift

class RedditPostViewController: UIViewController {
    
    /// `posts` dictionary keys
    private static let collectionTypeKey = "collectionType"
    private static let postsKey = "posts"
    private static let errorKey = "error"
    private static let isLoadingKey = "isLoading"
    
    /// Reuse identifiers for the table cells
    private let postCellReuseIdentifier = "postCell"
    private let loadingCellReuseIdentifier = "loadingCell"
    
    /**
     This array is the main workhorse of the view. Each element in the array is a dictionary with
     two values:
     
      - `collectionTypeKey`: A type of collection @see RedditCollectionType
      - `postsKey`: An array of RedditPost objects representing the posts we've loaded for that type so far.
      - `errorKey`: If there was an error in the most recent data fetch, this String will be set to tell why.
     
     Note: New collection types can be added effortlessly by simply adding a new dictionary to this array.
     */
    var posts = [
      [collectionTypeKey: RedditCollectionType.hot, postsKey: [RedditPost](), errorKey:nil, isLoadingKey:false],
      [collectionTypeKey: RedditCollectionType.new, postsKey: [RedditPost](), errorKey:nil, isLoadingKey:false],
      [collectionTypeKey: RedditCollectionType.top, postsKey: [RedditPost](), errorKey:nil, isLoadingKey:false]
    ]
    
    // TODO: The redit API for random posts doesn not seem to work the same as the others
    // Leaving this out for now
    //[collectionTypeKey: RedditCollectionType.random, postsKey: [RedditPost]()]

    /// The index (in the `posts` array) that the user is currently viewing
    var currentViewingIndex: Int  = 0
    
    /// Handles interaction with the Reddit API
    let redditAPI = RedditAPI()
    
    /// The number of posts we'll grab per API fetch
    let postBatchSize: Int = 15
    
    /// Once we reach this many posts remaining in the table view, we'll start loading the next batch
    /// A higher number can make the scrolling smoother, but may load data that the user never sees
    let beginLoadingNextBatchWithPostsRemaining = 5
    
    /// The progress indicator we'll use when first loading posts
    var progressHUD: MBProgressHUD?
    
    // The segmented control will allow the user to tab between post types
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
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.emptyDataSetSource = self
        tv.emptyDataSetDelegate = self
        tv.hideEmptyCells()
        tv.userDynamicCellHeightsWith(estimatedHeight: 80)
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = UITableViewCellSeparatorStyle.none
        tv.register(PostCell.self, forCellReuseIdentifier: postCellReuseIdentifier)
        tv.register(LoadingCell.self, forCellReuseIdentifier: loadingCellReuseIdentifier)
        return tv
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    lazy var loadingContainer: UIView = {
        let view = UIView.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        initialViewSetup()
        loadPostsTable(animated: false)
    }
    
    override func updateViewConstraints()
    {
        updateCollectionTypeSegmentedControlConstraints()
        updateTableViewConstraints()
        updateLoadingContainerConstraints()
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func presentCommentsFor(post: RedditPost)
    {
        print("Present commments for post: \(post)")
        let commentView = CommentViewController(withPost: post)
        self.navigationController?.pushViewController(commentView, animated: true)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl)
    {
        print("User did request to refresh!")
        loadPosts(after: nil)
    }

    /*
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
        })
    }*/
}

// MARK: - View Setup
private extension RedditPostViewController {
    
    func initialViewSetup()
    {
        setupNavigationBar()
        view.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(collectionTypeSegmentedControl)
        view.addSubview(loadingContainer)
        tableView.addSubview(refreshControl)
        view.addSubview(tableView)
    }
    
    func setupNavigationBar()
    {
        self.title = "Reddit Posts"
        // Removing the title from the back btn makes things look cleaner
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func updateTableViewConstraints()
    {
        tableView.topAnchor.constraint(equalTo: collectionTypeSegmentedControl.bottomAnchor, constant: 16.0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func updateLoadingContainerConstraints()
    {
        loadingContainer.topAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        loadingContainer.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
        loadingContainer.rightAnchor.constraint(equalTo: tableView.rightAnchor).isActive = true
        loadingContainer.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -70).isActive = true
    }
    
    func updateCollectionTypeSegmentedControlConstraints()
    {
        collectionTypeSegmentedControl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        collectionTypeSegmentedControl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        collectionTypeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    }
}


// MARK: - Reddit API
private extension RedditPostViewController {
    
    func loadPostsTable(animated: Bool)
    {
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
                    self.loadPosts(after: nil)
                }
            })
        })
    }
    
    func loadPosts(after: String?)
    {
        let postIndex = currentViewingIndex
        let collectionType = currentCollectionType()
        var loadedPosts = postsForCurrentCollectionType()
        
        // Mark that we're currently loading posts
        set(isLoading: true, forCollectionType: collectionType)
        
        // Remove any existing error before we start
        setError(message: nil, for: collectionType)
        
        // If we don't have any posts loaded yet, show an activity indicator
        if (loadedPosts.count == 0) {
            print("We don't have any loaded posts yet, show the activity indicator.")
            showPostActivityIndicatorFor(collectionType: collectionType)
        }
        
        redditAPI.postsFor(collectionType: collectionType, after: after, limit: postBatchSize, completion: { result in
            
            switch result {
                
            case .success(let newPosts):
                
                // If we're loading posts after a specific post, append them to the array
                // If we don't have an `after` value, then replace the entire array with a new array
                if (after == nil) {
                    loadedPosts.insert(contentsOf: newPosts as! Array<RedditPost>, at: 0)
                } else {
                    loadedPosts = newPosts as! Array<RedditPost>
                }
                
                self.posts[postIndex][RedditPostViewController.postsKey] = loadedPosts
                
            case .error(let code, let friendlyMessage, let cause):
                // Save a reference to this error message in case we need to show to the user
                print("Error [\(code)]: \(friendlyMessage) - Cause: \(cause)")
                self.setError(message: friendlyMessage, for: collectionType)
            }
            
            // Notify that we're done loading
            self.set(isLoading: false, forCollectionType: collectionType)
            
            // If we were using the refresh controll, stop now
            self.refreshControl.endRefreshing()
            
            // Reload the table view so any new results are shown
            self.tableView.reloadData()
            self.hidePostActivityIndicator()
        })
    }
}


// MARK: - Private Methods
private extension RedditPostViewController {
    
    // MARK: User Interaction
    
    @objc func collectionTypeDidChange(_ segmentedControl: UISegmentedControl)
    {
        currentViewingIndex = segmentedControl.selectedSegmentIndex
        loadPostsTable(animated: true)
    }
    
    // MARK: Current Collection Helpers
    
    func currentCollectionType() -> RedditCollectionType
    {
        return posts[currentViewingIndex][RedditPostViewController.collectionTypeKey] as! RedditCollectionType
    }
    
    func postsForCurrentCollectionType() -> Array<RedditPost>
    {
        return posts[currentViewingIndex][RedditPostViewController.postsKey] as! Array<RedditPost>
    }
    
    func lastLoadedPostNameInCurrentCollectionType() -> String?
    {
        if let lastPost = postsForCurrentCollectionType().last {
            return lastPost.name
        } else {
            return nil
        }
    }
    
    // MARK: Errors
    
    func errorForCurrentCollectionType() -> String?
    {
        return posts[currentViewingIndex][RedditPostViewController.errorKey] as? String
    }
    
    func setError(message: String?, for collectionType: RedditCollectionType)
    {
        if let index = indexFor(collectionType: collectionType) {
            posts[index][RedditPostViewController.errorKey] = message
        }
    }
    
    
    // MARK: Is Loading
    
    func currentCollectionTypeIsLoading() -> Bool
    {
        return posts[currentViewingIndex][RedditPostViewController.isLoadingKey] as! Bool
    }
    
    func set(isLoading: Bool, forCollectionType: RedditCollectionType)
    {
        if let index = indexFor(collectionType: forCollectionType) {
            posts[index][RedditPostViewController.isLoadingKey] = isLoading
        }
    }
    
    func indexFor(collectionType: RedditCollectionType) -> Int?
    {
        for (index, object) in posts.enumerated() {
            let type = object[RedditPostViewController.collectionTypeKey] as! RedditCollectionType
            if type == collectionType {
                return index
            }
        }
        return nil
    }
    
    
    // MARK: Has Next Page
    
    func hasNextPage() -> Bool
    {
        // TODO: Making a best guess here now, this would typically be grabbed from the API
        return postsForCurrentCollectionType().count >= postBatchSize
    }
    
    // MARK: Activity Indicator
    
    func showPostActivityIndicatorFor(collectionType: RedditCollectionType)
    {
        tableView.isHidden = true
        progressHUD = MBProgressHUD.showAdded(to: loadingContainer, animated: true)
        progressHUD?.label.text = "Loading \(collectionType.displayName()) posts..."
    }
    
    func hidePostActivityIndicator()
    {
        print("Hide progress HUD")
        tableView.isHidden = false
        progressHUD?.hide(animated: true)
    }
}


// MARK: - Table View Data Source
extension RedditPostViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let posts = postsForCurrentCollectionType()
        if (hasNextPage()) {
            return posts.count + 1 // Add in an extra cell for the 'loading' cell
        } else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let posts = postsForCurrentCollectionType()
        
        // If we're at the end of the table, show the activity indicator
        if (indexPath.row >= posts.count) {
            return loadingCellFor(tableView: tableView, atIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellReuseIdentifier, for: indexPath) as! PostCell
        let post = posts[indexPath.row]

        // A title is required for all posts
        cell.titleLabel.text = post.title
        
        // An author is not required, show as unkonwn if we don't have one
        let author = post.author ?? "Unkown"
        cell.authorLabel.text = "Posted by: \(author)"
        
        // Cell the thumbnail image (asyncronously)
        let aspectRation = post.expectedThumbnailAspectRatio()
        let placeholder = post.thumbnailPlaceholderImage()
        
        //post.thumbnailUrl = "https://i.redditmedia.com/OYz8bp8XFJyD--trIfvxTnWxGQIgQpAhGoOoq38DrrI.jpg?s=57f3aa21ccc6a0c073681595b3e10d30"
        //https://i.redditmedia.com/OYz8bp8XFJyD--trIfvxTnWxGQIgQpAhGoOoq38DrrI.jpg?s=57f3aa21ccc6a0c073681595b3e10d30
        post.printData()
        //print("[Cell]: Thumbnail URL: \(String(describing: post.thumbnailUrl))")
        
        cell.setThumbnailWith(urlString: post.thumbnailUrl, withExpectedAspectRatio: aspectRation, inTableViewOfWidth: UIScreen.main.bounds.width, placeholder: placeholder)
        
        return cell
    }
    
    func loadingCellFor(tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellReuseIdentifier, for: atIndexPath) as! LoadingCell
        cell.activityIndicator.startAnimating()
        return cell
    }
}

// MARK: - Table View Delegate
extension RedditPostViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        let posts = postsForCurrentCollectionType()
        let post = posts[indexPath.row]
        self.presentCommentsFor(post: post)
    }
    
    
    // TODO: THE FACT THAT WILL DISPLAY CELL IS BEING CALLED SO OFTEN IS MESSING THINGS UP,
    // NEED TO FIGURE OUT A SMOOTHER WAY TO HANDLE
    // THE FINAL CELL IS CALLED 3 OR 4 TIMES IN A ROW
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Once we get towards the bottom, we'll start loading more posts
        let lastIndex = tableView.numberOfRows(inSection: 0) - 1
        //let indexToStartLoadAt = tableView.numberOfRows(inSection: 0) - beginLoadingNextBatchWithPostsRemaining
        if ( indexPath.row == lastIndex && currentCollectionTypeIsLoading() == false) {
            //print("Load next page of data...")
            //let after = lastLoadedPostNameInCurrentCollectionType()
            //loadPosts(after: after)
        }
    }
    
    //let threshold = 100.0 // threshold from bottom of tableView
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !currentCollectionTypeIsLoading() && (maximumOffset - contentOffset <= 100) {
            print("Load next page of data...")
            let after = lastLoadedPostNameInCurrentCollectionType()
            loadPosts(after: after)
        }
    }*/
}

// MARK: - Empty Data Set Source
extension RedditPostViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        guard errorForCurrentCollectionType() != nil else {
            return nil
        }
        
        let title = "Error Loading Posts"
        let atts = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]
        return NSAttributedString.init(string: title, attributes: atts)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        guard let error = errorForCurrentCollectionType() else {
            return nil
        }

        let atts = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString.init(string: error, attributes: atts)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
    {
        return -100
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString?
    {
        guard errorForCurrentCollectionType() != nil else {
            return nil
        }
        
        let title = "Retry"
        let atts = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        return NSAttributedString.init(string: title, attributes: atts)
    }
    
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage?
    {
        guard errorForCurrentCollectionType() != nil else {
            return nil
        }
        
        let capInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let rectInsets = UIEdgeInsets(top: -19, left: -61, bottom: -19, right: -61)
        let image = UIImage.init(named: "empty-set-btn-bg")
        return image?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch).withAlignmentRectInsets(rectInsets)
    }
}

// MARK: - Empty Data Set Delegate
extension RedditPostViewController: EmptyDataSetDelegate {
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        loadPosts(after: nil)
    }
}

