# ThriveChallenge
A simple app to retrieve Reddit posts and comments. Choose from `Hot`, `New` or `Top` posts.

## Installation
The app should run as is.  If you have any questions or issues, please contact me.

## Notes
- The Reddit [API Docs](https://www.reddit.com/dev/api/) are not longer available, so I pieced together the API requests as best as I could. 
- Both the posts and comments are set to paginate.  Without the API docs, I could only implement a very basic setup for the comments that shows the top most level.
- The table cell for each post is calculated dynamically based on the title size and the size of the thumbnail image.

## TODO's / Future Addons
- Update comments view to show levels of comments (i.e. replies, replies to replies)
- Add support of .gif images.  A lot of the thumbnails are gif type. 
- Add in unit tests.
