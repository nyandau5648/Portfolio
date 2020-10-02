//
//  UploadTweetController.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/09.
//  Copyright © 2020 Newton. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class UploadTweetController: UIViewController {
    
    // MARK: - Properties
    
    public var user: Results<User>!
    private let realm = try! Realm()
    private let config: UploadTweetConfiguration
    private var tweets: [Tweet] = [Tweet]()
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.image = UIImage(named: "placeholderImg")
        return iv
    }()
    
    private let captionTextView = CaptionTextView()
    
    // MARK: - Lifecycle
    
    init(user: Results<User>!, config: UploadTweetConfiguration){
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChange(notification:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: captionTextView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Selecters
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUploadTweet(){
        view.endEditing(true)
        let tweetRealm = Tweet()
        let replyTweetRealm = ReplyTweet()
        guard let caption = captionTextView.text else { return }
        TweetService.shared.uploadTweet(caption: caption, type: config) {
            switch self.config {
            case .tweet:
                tweetRealm.caption = caption
                tweetRealm.tweetId = self.newId(model: tweetRealm)!
                try! self.realm.write {
                    self.realm.add(tweetRealm, update: .all)
                }
            case .reply(let tweet):
                replyTweetRealm.replyCaption = caption
                replyTweetRealm.replyTweetId = self.replyNewId(model: replyTweetRealm)!
                try! self.realm.write {
                    tweet.replyTweet.append(replyTweetRealm)
                }
                
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textViewDidChange(notification: NSNotification){
        let maxLength = 140
        let textView = notification.object as! UITextView
        if textView == captionTextView {
            if let text = textView.text {
                var eachCharacter = [Int]()
                for i in 0..<text.count {
                    let textIndex = text.index(text.startIndex, offsetBy: i)
                    eachCharacter.append(String(text[textIndex]).lengthOfBytes(using: String.Encoding.shiftJIS))
                }
                //文字変換が終了した時点で設定していた最大文字数を超えていた場合
                if textView.markedTextRange == nil && text.lengthOfBytes(using: String.Encoding.shiftJIS) > maxLength {
                    var countByte = 0
                    var countCharacter = 0
                    for n in eachCharacter {
                        if countByte < maxLength - 1 {
                            countByte += n
                            countCharacter += 1
                        }
                    }
                    //textFieldの文字にtextFieldの文字から最大文字数までの文字を入力(最大文字数以上削除して再入力)
                    textView.text = text.prefix(countCharacter).description
                }
            }
        }else{
            return
        }
    }
    
    private func newId<T: Object>(model: T) -> Int? {
        guard let key = T.primaryKey() else { return nil }
        if let last = realm.objects(T.self).sorted(byKeyPath: "tweetId", ascending: true).last,
            let lastId = last[key] as? Int {
            return lastId + 1
        } else {
            return 0
        }
    }
    
    private func replyNewId<T: Object>(model: T) -> Int? {
        guard let key = T.primaryKey() else { return nil }
        if let last = realm.objects(T.self).sorted(byKeyPath: "replyTweetId", ascending: true).last,
            let lastId = last[key] as? Int {
            return lastId + 1
        } else {
            return 0
        }
    }
    
    // MARK: - Helpers
    
    func configureUI(){
        try! realm.write {
            let userObject = realm.objects(User.self)
            view.backgroundColor = .white
            configureNavigationBar()
            let stack = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
            stack.axis = .horizontal
            stack.spacing = 12
            stack.alignment = .leading
            view.addSubview(stack)
            actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
            captionTextView.placeholderLabel.text = viewModel.placeholderText
            if userObject[0].profileImage != nil {
                profileImageView.image = UIImage(data: userObject[0].profileImage!)
            } else {
                profileImageView.image = UIImage(named: "placeholderImg")
            }
            stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)
        }
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
    }
    
}
