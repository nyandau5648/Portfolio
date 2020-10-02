//
//  AppDelegate.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/06.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = UserDefaults()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        openRealm()
        self.realmMigration()
        let dic = ["initialLaunch": true]
        defaults.register(defaults: dic)
        defaults.synchronize()

        if defaults.bool(forKey: "initialLaunch") == true {
            print("initial setup start")
            self.initialSetUp()
        }
        
        return true
    }
    
    func initialSetUp() {
        self.realmMigration()
        self.defaults.set(false, forKey: "initialLaunch")
        self.defaults.synchronize()
    }
    
    func realmMigration(){
        var config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 1 {
                migration.enumerateObjects(ofType: User.className()) { oldObject, newObject in
                    let username = oldObject!["username"] as! String
                    let fullname = oldObject!["fullname"] as! String
                    let profileText = oldObject?["profileText"] as? String
                    let profileImage = oldObject!["profileImage"] as! Data
                    let tweets = oldObject!["tweets"] as? List<Tweet>
                    newObject!["username"] = username
                    newObject!["fullname"] = fullname
                    newObject!["profileImage"] = profileImage
                    newObject?["profieText"] = profileText
                    newObject?["tweets"] = tweets
                }
                migration.enumerateObjects(ofType: Tweet.className()) { oldObject, newObject in
                    let caption = oldObject!["caption"] as! String
                    let timestamp = oldObject!["timestamp"] as! Date
                    let retweetCount = oldObject?["retweetCount"] as! Int
                    let likes = oldObject!["likes"] as! Int
                    let didLike = oldObject!["didLike"] as! Bool
                    let replyingTo = oldObject!["replyingTo"] as! String
                    let isReply = oldObject!["isReply"] as! Bool
                    let replyTweet = oldObject!["replyTweet"] as? List<ReplyTweet>
                    newObject!["caption"] = caption
                    newObject!["timestamp"] = timestamp
                    newObject?["retweetCount"] = retweetCount
                    newObject?["likes"] = likes
                    newObject?["didLike"] = didLike
                    newObject?["replyingTo"] = replyingTo
                    newObject?["isReply"] = isReply
                    newObject?["replyTweet"] = replyTweet
                }
                migration.enumerateObjects(ofType: ReplyTweet.className()) { oldObject, newObject in
                    let replyCaption = oldObject!["replyCaption"] as! String
                    let replyTimeStamp = oldObject!["replyTimeStamp"] as! Date
                    let replyRetweetCount = oldObject?["replyRetweetCount"] as! Int
                    let likes = oldObject!["likes"] as! Int
                    let didLike = oldObject!["didLike"] as! Bool
                    let replyingTo = oldObject!["replyingTo"] as! String
                    let isReply = oldObject!["isReply"] as! Bool
                    newObject!["replyCaption"] = replyCaption
                    newObject!["replyTimeStamp"] = replyTimeStamp
                    newObject?["replyRetweetCount"] = replyRetweetCount
                    newObject?["likes"] = likes
                    newObject?["didLike"] = didLike
                    newObject?["replyingTo"] = replyingTo
                    newObject?["isReply"] = isReply
                }
            }
            if oldSchemaVersion < 2 {
            }
        })
        config.schemaVersion += 1
        Realm.Configuration.defaultConfiguration = config
    }
    
    func openRealm() {
        let defaultRealmPath = Realm.Configuration.defaultConfiguration.fileURL!
        let bundleRealmPath = Bundle.main.url(forResource: "default_V0", withExtension: "realm")
        if FileManager.default.fileExists(atPath: defaultRealmPath.path) {
            return
        }
        do {
            try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
        } catch let error {
            print("error copying realm file: \(error)")
        }
        
        if !FileManager.default.fileExists(atPath: defaultRealmPath.path) {
            do {
                try FileManager.default.copyItem(at: bundleRealmPath!, to: defaultRealmPath)
            } catch let error {
                print("error copying seeds: \(error)")
            }
        }
        
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

