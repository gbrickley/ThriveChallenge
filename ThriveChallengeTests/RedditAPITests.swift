//
//  RedditAPITests.swift
//  ThriveChallengeTests
//
//  Created by George Brickley on 8/4/18.
//  Copyright © 2018 George Brickley. All rights reserved.
//

import XCTest
@testable import ThriveChallenge

class RedditAPITests: XCTestCase {
    
    var redditAPI: RedditAPI?
    
    override func setUp() {
        super.setUp()
        redditAPI = nil
    }
    
    override func tearDown() {
        redditAPI = RedditAPI()
        super.tearDown()
    }
    
    func testPostGetRequest() {
        // TODO: IMPLEMENT
    }
    
    func testCommentGetRequest() {
        // TODO: IMPLEMENT
    }
}
