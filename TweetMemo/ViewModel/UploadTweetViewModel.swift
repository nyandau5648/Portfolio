//
//  UploadTweetViewModel.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/12.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

enum UploadTweetConfiguration {
    case tweet
    case reply(Tweet)
}

struct UploadTweetViewModel {
    
    let actionButtonTitle: String
    let placeholderText: String
    var shouldShowReplyLabel: Bool
    var replyText: String?
    
    init(config: UploadTweetConfiguration){
        switch config {
        case .tweet:
            actionButtonTitle = "ツイート"
            placeholderText = "今何してる？"
            shouldShowReplyLabel = false
        case .reply(let tweet):
            actionButtonTitle = "返信"
            placeholderText = "返信してみよう！"
            shouldShowReplyLabel = true
            replyText = "Replying to @\(tweet.users)"
        }
    }
    
}
