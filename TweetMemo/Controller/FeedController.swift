//
//  FeedController.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/06.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift
import ActiveLabel

private let reuseIdentifier = "TweetCell"
private let headeerIdentifier = "TweetHeader"
private let realm = try! Realm()
private let userObject = Array(realm.objects(User.self))
private let tweetObject = Array(realm.objects(Tweet.self))

class FeedController: UICollectionViewController {
    
    //MARK: - Properties
    
    private var profileImage: UIImage?
    var viewControllers: [UIViewController] = []
    public var user: Results<User>! {
        didSet {
            guard let nav = viewControllers[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
            configureLeftBarButton()
        }
    }
    
    private var tweets: [Tweet] = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    private var tweet: Tweet = Tweet() {
        didSet { collectionView.reloadData() }
    }
    
    let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "baseline_playlist_add_white_36pt_1x"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()

    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.setRealm()
        self.configureUI()
        self.fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setRealm()
        self.fetchTweets()
        self.configureUI()
        self.collectionView.reloadData()
    }
    
    // MARK: - API
    
    private func fetchTweets(){
        self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    // MARK: - Selectors
    
    @objc func handleRefresh(){
        fetchTweets()
    }
    
    @objc func handleProfileImageTap() {
        if userObject[0].id == 0 {
            let controller = ProfileController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    //MARK: - Helpers
    
    private func configureUI(){
        view.backgroundColor = .white
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56)
        actionButton.layer.cornerRadius = 56 / 2
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        configureLeftBarButton()
    }
    
    private func configureLeftBarButton(){
        let profileImageView = UIImageView()
        try! realm.write {
            if userObject[0].profileImage != nil {
                profileImageView.image = UIImage(data: userObject[0].profileImage!)
            } else {
                profileImageView.image = UIImage(named: "placeholderImg")
            }
        }
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleProfileImageTap))
        profileImageView.addGestureRecognizer(tap)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    @objc func actionButtonTapped(){
        let controller = UploadTweetController(user: user, config: .tweet)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    public func setRealm(){
        tweets = Array(realm.objects(Tweet.self))
        collectionView.reloadData()
    }
    
    public func getTimeStamp(from: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: from)
    }
    
}

// MARK: - UICollectionViewDelegate/DataSource

extension FeedController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        let tweetObject = tweets[indexPath.row]
        cell.tweets = tweetObject
//        for index in tweets.enumerated() {
//            print("Index is \(index)")
//
//        }
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
            cell.likeButton.tintColor = .red
            cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
        }
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweets: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweetObject = tweets[indexPath.row]
        func size(forWidth width: CGFloat) -> CGSize {
            let measurementLabel = UILabel()
            measurementLabel.text = tweetObject.caption
            measurementLabel.numberOfLines = 0
            measurementLabel.lineBreakMode = .byWordWrapping
            measurementLabel.translatesAutoresizingMaskIntoConstraints = false
            measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
        let height = size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 80)
    }
    
}

// MARK: - TweetCellDelegate

extension FeedController: TweetCellDelegate {
    
    func handleFetchUser(withUsername username: String) {
        let controller = ProfileController(user: user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
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
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        let tweet = cell.tweets
        let controller = UploadTweetController(user: user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleShareTapped(_ cell: TweetCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let tweetObject = tweets[indexPath!.row]
        let controller = UIActivityViewController(activityItems: [tweetObject.caption], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func deleteActionSheet(_ cell: TweetCell) {
        let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { [self] (action: UIAlertAction!) -> Void in
            let indexPath = self.collectionView.indexPath(for: cell)
            let tweetObject = self.tweets[indexPath!.row]
            try! realm.write {
                realm.delete(tweetObject.replyTweet)
                realm.delete(tweetObject)
                self.tweets.remove(at: indexPath!.row)
            }
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
        alert.pruneNegativeWidthConstraints()
        self.present(alert, animated: true, completion: nil)
    }

}

public extension UIImage {

    func toPNGData() -> Data {
        guard let data = self.pngData() else {
            print("The image could not be converted to PNG data.")
            return Data()
        }
        return data as Data
    }

    func toJPEGData() -> Data {
        guard let data = self.jpegData(compressionQuality: 1.0) else {
            print("The image could not be converted to JPEG data.")
            return Data()
        }
        return data as Data
    }

}

extension UIAlertController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        pruneNegativeWidthConstraints()
    }

    public func pruneNegativeWidthConstraints() {
        if #available(iOS 13.0, *) {
            for subView in self.view.subviews {
                for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                    subView.removeConstraint(constraint)
                }
            }
        }
    }
}
