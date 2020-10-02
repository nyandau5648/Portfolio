//
//  ProfileController.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/10.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"
private let realm = try! Realm()
private let userObject = Array(realm.objects(User.self))
private let tweetObject = Array(realm.objects(Tweet.self))

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: Results<User>!
    private var tweets: [Tweet] = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet { collectionView.reloadData() }
    }
    
    private var replyTweet = [ReplyTweet]()
    private var replyLikedTweet = [ReplyTweet]()
    
    private var resultTweetLike = Array(realm.objects(Tweet.self).filter("didLike == true"))
    private var resultReplyLike = Array(realm.objects(ReplyTweet.self).filter("didLike == true"))
    
    // MARK: - Lifecycle
    
    init(user: Results<User>!) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        
        replyTweet = Array(realm.objects(ReplyTweet.self))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setRealm()
        self.collectionView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func checkIfUserIsFollowed(){
        self.collectionView.reloadData()
    }
    
    // MARK: - Helper
    
    func configureCollectionView(){
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    public func setRealm(){
        let realm = try! Realm()
        tweets = Array(realm.objects(Tweet.self))
        collectionView.reloadData()
    }
    
    public func getTimeStamp(from: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: from)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.selectedFilter {
        case .tweets:
            return tweets.count
        case .replies:
            return replyTweet.count
        case .likes:
            return resultTweetLike.count + resultReplyLike.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        switch self.selectedFilter {
        case .tweets:
            let tweetObject = tweets[indexPath.row]
            cell.tweets = tweetObject
            
            let title = NSMutableAttributedString(string: userObject[0].fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            title.append(NSAttributedString(string: " @\(userObject[0].username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                       .foregroundColor: UIColor.lightGray]))
            title.append(NSAttributedString(string: "・\(self.getTimeStamp(from: tweetObject.timestamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                       .foregroundColor: UIColor.lightGray]))
            cell.captionLabel.text = tweetObject.caption
            cell.infoLabel.attributedText = title
            if tweetObject.didLike == false {
                cell.likeButton.tintColor = .lightGray
                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            } else {
                let resultLike = realm.objects(Tweet.self).filter("didLike == true")
                likedTweets = Array(resultLike)
                cell.likeButton.tintColor = .red
                cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
            }
        case .replies:
            let replyTweetObject = replyTweet[indexPath.row]
            cell.replyTweets = replyTweetObject
            let count = replyTweet.count
            if indexPath.row < count {
                cell.captionLabel.text = replyTweet[indexPath.row].replyCaption
            }
            let title = NSMutableAttributedString(string: userObject[0].fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            title.append(NSAttributedString(string: " @\(userObject[0].username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                       .foregroundColor: UIColor.lightGray]))
            title.append(NSAttributedString(string: "・\(self.getTimeStamp(from: replyTweetObject.replyTimeStamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                       .foregroundColor: UIColor.lightGray]))
            cell.captionLabel.text = replyTweetObject.replyCaption
            cell.infoLabel.attributedText = title
            if replyTweetObject.didLike == false {
                cell.likeButton.tintColor = .lightGray
                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
            } else {
                let resultReplyLike = realm.objects(ReplyTweet.self).filter("didLike == true")
                replyLikedTweet = Array(resultReplyLike)
                cell.likeButton.tintColor = .red
                cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
            }
        case .likes:
            let resultTweetLikeCount = resultTweetLike.count
            if indexPath.row < resultTweetLikeCount {
                let resultTweetLikeObject = resultTweetLike[indexPath.row]
                cell.tweets = resultTweetLikeObject
                let title = NSMutableAttributedString(string: userObject[0].fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                title.append(NSAttributedString(string: " @\(userObject[0].username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                           .foregroundColor: UIColor.lightGray]))
                title.append(NSAttributedString(string: "・\(self.getTimeStamp(from: resultTweetLikeObject.timestamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                           .foregroundColor: UIColor.lightGray]))
                cell.captionLabel.text = resultTweetLikeObject.caption
                cell.infoLabel.attributedText = title
                if resultTweetLikeObject.didLike == false {
                    cell.likeButton.tintColor = .lightGray
                    cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                } else {
                    let resultLike = realm.objects(Tweet.self).filter("didLike == true")
                    likedTweets = Array(resultLike)
                    cell.likeButton.tintColor = .red
                    cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                }
            } else {
                let minusTweet = indexPath.row - resultTweetLikeCount
                let resultReplyTweetLikeObject = resultReplyLike[minusTweet]
                cell.replyTweets = resultReplyTweetLikeObject
                
                let replyTitle = NSMutableAttributedString(string: userObject[0].fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                replyTitle.append(NSAttributedString(string: " @\(userObject[0].username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                           .foregroundColor: UIColor.lightGray]))
                replyTitle.append(NSAttributedString(string: "・\(self.getTimeStamp(from: resultReplyTweetLikeObject.replyTimeStamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                           .foregroundColor: UIColor.lightGray]))
                cell.captionLabel.text = resultReplyTweetLikeObject.replyCaption
                cell.infoLabel.attributedText = replyTitle
                if resultReplyTweetLikeObject.didLike == false {
                    cell.likeButton.tintColor = .lightGray
                    cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                } else {
                    let resultLike = realm.objects(Tweet.self).filter("didLike == true")
                    likedTweets = Array(resultLike)
                    cell.likeButton.tintColor = .red
                    cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                }
            }
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        header.configure()
        return header
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        func size(forWidth width: CGFloat) -> CGSize {
            let measurementLabel = UILabel()
            measurementLabel.numberOfLines = 0
            measurementLabel.text = userObject[0].profileText
            measurementLabel.lineBreakMode = .byWordWrapping
            measurementLabel.translatesAutoresizingMaskIntoConstraints = false
            measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
        let height = size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 280)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch selectedFilter {
        case .tweets:
            func size(forWidth width: CGFloat) -> CGSize {
                let measurementLabel = UILabel()
                measurementLabel.numberOfLines = 0
                measurementLabel.text = tweets[indexPath.row].caption
                measurementLabel.lineBreakMode = .byWordWrapping
                measurementLabel.translatesAutoresizingMaskIntoConstraints = false
                measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            }
            let height = size(forWidth: view.frame.width).height
            return CGSize(width: view.frame.width, height: height + 100)
        case .replies:
            func size(forWidth width: CGFloat) -> CGSize {
                let measurementLabel = UILabel()
                measurementLabel.numberOfLines = 0
                measurementLabel.text = replyTweet[indexPath.row].replyCaption
                measurementLabel.lineBreakMode = .byWordWrapping
                measurementLabel.translatesAutoresizingMaskIntoConstraints = false
                measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            }
            let height = size(forWidth: view.frame.width).height
            return CGSize(width: view.frame.width, height: height + 100)
        case .likes:
            let count = resultTweetLike.count
            if indexPath.row < count {
                func size(forWidth width: CGFloat) -> CGSize {
                    let measurementLabel = UILabel()
                    measurementLabel.numberOfLines = 0
                    measurementLabel.text = resultTweetLike[indexPath.row].caption
                    measurementLabel.lineBreakMode = .byWordWrapping
                    measurementLabel.translatesAutoresizingMaskIntoConstraints = false
                    measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                    return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                }
                let height = size(forWidth: view.frame.width).height
                return CGSize(width: view.frame.width, height: height + 100)
            } else {
                let minusTweet = indexPath.row - count
                func size(forWidth width: CGFloat) -> CGSize {
                    let measurementLabel = UILabel()
                    measurementLabel.numberOfLines = 0
                    measurementLabel.text = resultReplyLike[minusTweet].replyCaption
                    measurementLabel.lineBreakMode = .byWordWrapping
                    measurementLabel.translatesAutoresizingMaskIntoConstraints = false
                    measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
                    return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
                }
                let height = size(forWidth: view.frame.width).height
                return CGSize(width: view.frame.width, height: height + 100)
            }
        }
    }
    
}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    
    func didSelect(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        let controller = EditProfileController(user: user)
        controller.delegate = self as? EditProfileControllerDelegate
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        return
    }
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension ProfileController: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        let controller = EditProfileController(user: user)
        controller.delegate = self as? EditProfileControllerDelegate
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        switch selectedFilter {
        case .tweets:
            let tweet = cell.tweets
            let controller = UploadTweetController(user: user, config: .reply(tweet))
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .replies:
            let tweet = cell.tweets
            let controller = UploadTweetController(user: user, config: .reply(tweet))
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        case .likes:
        let tweet = cell.tweets
        let controller = UploadTweetController(user: user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        }
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        switch selectedFilter {
        case .tweets:
            let indexPath = self.collectionView.indexPath(for: cell)
            let tweetObject = tweets[indexPath!.row]
            try! realm.write {
                tweetObject.didLike.toggle()
                if tweetObject.didLike == false {
                    cell.likeButton.tintColor = .lightGray
                    cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                    tweetObject.likes -= 1
                    realm.add(tweetObject, update: .all)
                } else {
                    cell.likeButton.tintColor = .red
                    cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                    tweetObject.likes += 1
                    realm.add(tweetObject, update: .all)
                }
            }
        case .replies:
            let indexPath = self.collectionView.indexPath(for: cell)
            let tweetObject = replyTweet[indexPath!.row]
            try! realm.write {
                tweetObject.didLike.toggle()
                if tweetObject.didLike == false {
                    cell.likeButton.tintColor = .lightGray
                    cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                    tweetObject.likes -= 1
                    realm.add(tweetObject, update: .all)
                } else {
                    cell.likeButton.tintColor = .red
                    cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                    tweetObject.likes += 1
                    realm.add(tweetObject, update: .all)
                }
            }
        case .likes:
        let indexPath = self.collectionView.indexPath(for: cell)
        let count = resultTweetLike.count
        let tweetObject = tweets[indexPath!.row]
        let replyTweetObject = replyTweet[indexPath!.row]
            if indexPath!.row < count {
                try! realm.write {
                    tweetObject.didLike.toggle()
                    if tweetObject.didLike == false {
                        cell.likeButton.tintColor = .lightGray
                        cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                        tweetObject.likes -= 1
                        realm.add(tweetObject, update: .all)
                    } else {
                        cell.likeButton.tintColor = .red
                        cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                        tweetObject.likes += 1
                        realm.add(tweetObject, update: .all)
                    }
                }
            } else {
                try! realm.write {
                    replyTweetObject.didLike.toggle()
                    if tweetObject.didLike == false {
                        cell.likeButton.tintColor = .lightGray
                        cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                        tweetObject.likes -= 1
                        realm.add(tweetObject, update: .all)
                    } else {
                        cell.likeButton.tintColor = .red
                        cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                        tweetObject.likes += 1
                        realm.add(tweetObject, update: .all)
                    }
                }
            }
        }
    }
    
    func handleShareTapped(_ cell: TweetCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        switch selectedFilter {
        case .tweets:
            let tweetObject = tweets[indexPath!.row]
            let controller = UIActivityViewController(activityItems: [tweetObject.caption], applicationActivities: nil)
            self.present(controller, animated: true, completion: nil)
        case .replies:
            let replyTweetObject = replyTweet[indexPath!.row]
            let controller = UIActivityViewController(activityItems: [replyTweetObject.replyCaption], applicationActivities: nil)
            self.present(controller, animated: true, completion: nil)
        case .likes:
            let count = resultTweetLike.count
            let minusTweet = indexPath!.row - count
            if indexPath!.row < count {
                let controller = UIActivityViewController(activityItems: [resultTweetLike[indexPath!.row].caption], applicationActivities: nil)
                self.present(controller, animated: true, completion: nil)
            } else {
                let controller = UIActivityViewController(activityItems: [resultReplyLike[minusTweet].replyCaption], applicationActivities: nil)
                self.present(controller, animated: true, completion: nil)
            }
            
        }
    }
    
    func deleteActionSheet(_ cell: TweetCell) {
        switch selectedFilter {
        case .tweets:
            let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
                let indexPath = self.collectionView.indexPath(for: cell)
                let tweetObject = self.tweets[indexPath!.row]
                if tweetObject.replyTweet.isEmpty {
                    try! realm.write {
                        self.resultTweetLike.removeAll(where: { $0.tweetId == tweetObject.tweetId })
                        realm.delete(tweetObject.replyTweet)
                        realm.delete(tweetObject)
                        self.tweets.remove(at: indexPath!.row)
                    }
                } else {
                    let replyTweetsLikeFilter = tweetObject.replyTweet.filter { $0.didLike == true }
                    try! realm.write {
                        replyTweetsLikeFilter.forEach { [weak self] likedTweet in
                            self?.resultReplyLike.removeAll(where: { $0.replyTweetId == likedTweet.replyTweetId })
                        }
                        tweetObject.replyTweet.forEach { [weak self]  replyTweets in
                            self?.replyTweet.removeAll(where: { $0.replyTweetId == replyTweets.replyTweetId })
                        }
                        self.resultTweetLike.removeAll(where: { $0.tweetId == tweetObject.tweetId })
                        self.tweets.removeAll(where: { $0.tweetId == tweetObject.tweetId })
                        realm.delete(tweetObject.replyTweet)
                        realm.delete(tweetObject)
                    }
                }
                self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
            alert.pruneNegativeWidthConstraints()
            self.present(alert, animated: true, completion: nil)
        case .replies:
            let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
                let indexPath = self.collectionView.indexPath(for: cell)
                let replyTweetObject = self.replyTweet[indexPath!.row]
                try! realm.write {
                    self.resultReplyLike.removeAll(where: { $0.replyTweetId == replyTweetObject.replyTweetId })
                    realm.delete(replyTweetObject)
                    self.replyTweet.remove(at: indexPath!.row)
                }
                self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
            alert.pruneNegativeWidthConstraints()
            self.present(alert, animated: true, completion: nil)
        case .likes:
            let indexPath = self.collectionView.indexPath(for: cell)
            let resultTweetLikeCount = resultTweetLike.count
            let minusTweet = indexPath!.row - resultTweetLikeCount
            if indexPath!.row < resultTweetLikeCount {
                let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { [self] (action: UIAlertAction!) -> Void in
                    let resultTweetLikeObject = resultTweetLike[indexPath!.row]
                    if resultTweetLikeObject.replyTweet.isEmpty {
                        try! realm.write {
                            self.resultTweetLike.removeAll(where: { $0.tweetId == resultTweetLikeObject.tweetId })
                            self.tweets.removeAll(where: { $0.tweetId == resultTweetLikeObject.tweetId } )
                            realm.delete(resultTweetLikeObject)
                        }
                    } else {
                        let resultTweetLikeObject = resultTweetLike[indexPath!.row]
                        let replyTweetsLikeFilter = replyTweet.filter { $0.didLike == true }
                        try! realm.write {
                            replyTweetsLikeFilter.forEach { [weak self] likedTweet in
                                self?.resultReplyLike.removeAll(where: { $0.replyTweetId == likedTweet.replyTweetId })
                            }
                            resultTweetLikeObject.replyTweet.forEach { [weak self]  replyTweets in
                                self?.replyTweet.removeAll(where: { $0.replyTweetId == replyTweets.replyTweetId })
                            }
                            self.resultTweetLike.removeAll(where: { $0.tweetId == resultTweetLikeObject.tweetId })
                            self.tweets.removeAll(where: { $0.tweetId == resultTweetLikeObject.tweetId })
                            realm.delete(resultTweetLikeObject.replyTweet)
                            realm.delete(resultTweetLikeObject)
                        }
                    }
                    self.collectionView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
                alert.pruneNegativeWidthConstraints()
                self.present(alert, animated: true, completion: nil)
            } else {
                let resultReplyTweetLikeObject = resultReplyLike[minusTweet]
                let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
                    try! realm.write {
                        self.resultReplyLike.removeAll(where: { $0.replyTweetId == resultReplyTweetLikeObject.replyTweetId })
                        self.replyTweet.removeAll(where: { $0.replyTweetId == resultReplyTweetLikeObject.replyTweetId })
                        realm.delete(resultReplyTweetLikeObject)
                    }
                    self.collectionView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
                alert.pruneNegativeWidthConstraints()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
