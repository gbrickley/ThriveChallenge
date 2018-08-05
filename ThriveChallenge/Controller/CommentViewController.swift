//
//  CommentViewController.swift
//  ThriveChallenge
//
//  Created by George Brickley on 8/4/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import UIKit
import MBProgressHUD
import EmptyDataSet_Swift

class CommentViewController: UIViewController {
    
    /// Reuse identifiers for the table cells
    private let commentCellReuseIdentifier = "postCell"
    private let loadingCellReuseIdentifier = "loadingCell"
    
    // The id of the post we're displaying comments for
    // A post is required, and should be set in the init: method
    var post:RedditPost!
    
    /// This array will hold the currently loaded comments
    var comments = [PostComment]()
    
    /// If we encountered an error loading comments, we'll store the message here
    var error: String?
    
    /// Tracks whether or not we're currently loading comments from the API
    var isLoading = false
    
    /// Handles interaction with the Reddit API
    let redditAPI = RedditAPI()
    
    /// The number of comments we'll grab per API fetch
    let commentBatchSize: Int = 15
        
    /// The progress indicator we'll use when first loading posts
    var progressHUD: MBProgressHUD?
    
    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        tv.emptyDataSetSource = self
        tv.emptyDataSetDelegate = self
        tv.hideEmptyCells()
        tv.userDynamicCellHeightsWith(estimatedHeight: 180)
        tv.backgroundColor = UIColor.clear
        tv.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tv.register(CommentCell.self, forCellReuseIdentifier: commentCellReuseIdentifier)
        tv.register(LoadingCell.self, forCellReuseIdentifier: loadingCellReuseIdentifier)
        return tv
    }()
    
    /// The comment view must always be initialized with a post object
    init(withPost post: RedditPost)
    {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Must use init(post:) when creating instances of CommentViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Comments"
        initialViewSetup()
        loadNextPageOfComments()
    }
    
    override func updateViewConstraints()
    {
        updateTableViewConstraints()
        super.updateViewConstraints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - View Setup
private extension CommentViewController {
    
    func initialViewSetup()
    {
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
    }
    
    func updateTableViewConstraints()
    {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}


// MARK: - Reddit API
private extension CommentViewController {
    
    func loadNextPageOfComments()
    {
        // Mark that we're currently loading posts
        isLoading = true
        
        // Remove any existing error before we start
        error = nil
        
        // If we have some comments already loaded, we'll grab comments after the last one
        let after = lastLoadedCommentName()
        
        // If we don't have any comments loaded yet, show an activity indicator
        if (comments.count == 0) {
            showCommentActivityIndicatorFor()
        }
        
        redditAPI.commentsForPostWithId(postId: post.uid, after: after, limit: commentBatchSize, completion: { result in
            
            switch result {
                
            case .success(let newComments):
                // TODO: Manually sorting comments for now.  Reddit API does not document how to sort.
                let unsortedComments = newComments as! Array<PostComment>
                let sortedComments = unsortedComments.sorted(by: { $0.postDateTimestamp > $1.postDateTimestamp })
                
                // Add the new comments to the comments array
                self.add(newComments: sortedComments)
                
            case .error(let code, let friendlyMessage, let cause):
                // Save a reference to this error message in case we need to show to the user
                print("Error [\(code)]: \(friendlyMessage) - Cause: \(cause)")
                self.error = friendlyMessage
                self.tableView.reloadData()
            }
            
            // Notify that we're done loading
            self.isLoading = false
            
            // Reload the table view so any new results are shown
            self.hideCommentActivityIndicator()
        })
    }
    
    func add(newComments: Array<PostComment>)
    {
        if (comments.count == 0) {
            comments.append(contentsOf: newComments)
            self.tableView.reloadData()
            return
        }
        
        // We add the comments to the comments array and then insert a table row for each new item
        // Adding individual rows, as opposed to reloading the entire table view, makes
        // for a better user experience (keeps the users scroll position)
        var indexPaths = [IndexPath]()
        
        for comment in newComments {
            comments.append(comment)
            if let row = comments.index(of: comment) {
                let indexPath = IndexPath(row: row, section: 0)
                indexPaths.append(indexPath)
            }
        }
        
        tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
    }
}


// MARK: - Private Methods
private extension CommentViewController {
    
    // MARK: Loading Helpers
    
    func lastLoadedCommentName() -> String?
    {
        if let lastComment = comments.last {
            return lastComment.name
        } else {
            return nil
        }
    }
    
    func hasNextPage() -> Bool
    {
        // TODO: Making a best guess here now, this would typically be grabbed from the API
        return comments.count >= commentBatchSize
    }
    
    
    // MARK: Activity Indicator
    
    func showCommentActivityIndicatorFor()
    {
        tableView.isHidden = true
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD?.label.text = "Loading comments..."
    }
    
    func hideCommentActivityIndicator()
    {
        tableView.isHidden = false
        progressHUD?.hide(animated: true)
    }
}


// MARK: - Table View Data Source
extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (hasNextPage()) {
            return comments.count + 1 // Add in an extra cell for the 'loading' cell
        } else {
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // If we're at the end of the table, show the activity indicator
        if (indexPath.row >= comments.count) {
            return loadingCellFor(tableView: tableView, atIndexPath: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellReuseIdentifier, for: indexPath) as! CommentCell
        let comment = comments[indexPath.row]
        
        cell.authorLabel.text = comment.author
        cell.dateLabel.text = comment.postDate().asRelativeDateString()
        cell.commentLabel.text = comment.body

        return cell
    }
    
    func loadingCellFor(tableView: UITableView, atIndexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: loadingCellReuseIdentifier, for: atIndexPath) as! LoadingCell
        cell.set(height: 50)
        cell.activityIndicator.startAnimating()
        return cell
    }
}

// MARK: - Table View Delegate
extension CommentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        // Once we get to the bottom, we'll start loading more posts
        if ( indexPath.row == comments.count && !isLoading && hasNextPage()) {
            self.loadNextPageOfComments()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // In order to give a better experience when paginating, we want the bottom of the
        // table view to NOT bounce.  But, we do want the top of the table view to bouce
        // (we need this in order to use refresh control)
        if (scrollView.contentOffset.y > 100 && hasNextPage()) {
            tableView.bounces = false
        } else {
            tableView.bounces = true
        }
    }
}

// MARK: - Empty Data Set Source
extension CommentViewController: EmptyDataSetSource {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        var title = "No Comments Yet"
        if error != nil {
            title = "Error Loading Comments"
        }
    
        let atts = [NSAttributedStringKey.foregroundColor: UIColor.black, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17)]
        return NSAttributedString.init(string: title, attributes: atts)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString?
    {
        var descrip = "Check back later once others have commented..."
        if let error = error {
            descrip = error
        }
        
        let atts = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        return NSAttributedString.init(string: descrip, attributes: atts)
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat
    {
        return -100
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> NSAttributedString?
    {
        guard error != nil else {
            return nil
        }
        
        let title = "Retry"
        let atts = [NSAttributedStringKey.foregroundColor: UIColor.gray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        return NSAttributedString.init(string: title, attributes: atts)
    }
    
    func buttonBackgroundImage(forEmptyDataSet scrollView: UIScrollView, for state: UIControlState) -> UIImage?
    {
        guard error != nil else {
            return nil
        }
        
        let capInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let rectInsets = UIEdgeInsets(top: -19, left: -61, bottom: -19, right: -61)
        let image = UIImage.init(named: "empty-set-btn-bg")
        return image?.resizableImage(withCapInsets: capInsets, resizingMode: .stretch).withAlignmentRectInsets(rectInsets)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage?
    {
        if error == nil {
            return UIImage(named: "comment-empty-set")
        } else {
            return nil
        }
    }
}

// MARK: - Empty Data Set Delegate
extension CommentViewController: EmptyDataSetDelegate {
    
    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        loadNextPageOfComments()
    }
}
