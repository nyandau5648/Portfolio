//
//  Tweet.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/09.
//  Copyright © 2020 Newton. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Tweet: Object {
    
    @objc dynamic var tweetId: Int = 0
    @objc dynamic var caption: String = ""
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var retweetCount: Int = 0
    @objc dynamic var likes: Int = 0
    @objc dynamic var didLike = false
    @objc dynamic var replyingTo: String?
    @objc dynamic var isReply: Bool { return replyingTo != nil }
    
    let users = LinkingObjects(fromType: User.self, property: "tweets")
    
    var replyTweet = List<ReplyTweet>()
    
    override static func primaryKey() -> String? {
        return "tweetId"
    }
    
}

class ReplyTweet: Object {
    
    @objc dynamic var replyTweetId: Int = 0
    @objc dynamic var replyCaption: String = ""
    @objc dynamic var replyTimeStamp: Date = Date()
    @objc dynamic var replyRetweetCount: Int = 0
    @objc dynamic var likes: Int = 0
    @objc dynamic var didLike = false
    @objc dynamic var replyingTo: String?
    @objc dynamic var isReply: Bool { return replyingTo != nil }
    
    let replyTweets = LinkingObjects(fromType: Tweet.self, property: "replyTweet")
    
    override static func primaryKey() -> String? {
        return "replyTweetId"
    }
    
}
