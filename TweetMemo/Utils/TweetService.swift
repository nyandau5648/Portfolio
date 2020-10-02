//
//  TweetService.swift
//  TweetMemo
//
//  Created by Newton on 2020/09/05.
//  Copyright © 2020 Newton. All rights reserved.
//

import RealmSwift

struct TweetService {
    
    static let shared = TweetService()
    
    public var user: Results<User>!
    private let realm = try! Realm()
    
    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping() -> Void){
        completion()
    }
    
}
