////
////  TweetController.swift
////  TweetMemo
////
////  Created by Newton on 2020/05/12.
////  Copyright © 2020 Newton. All rights reserved.
////
//
import UIKit
import RealmSwift

private let reuseIdentifier = "TweetCell"
private let headeerIdentifier = "TweetHeader"
private let realm = try! Realm()
private let userObject = Array(realm.objects(User.self))

class TweetController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let realm = try! Realm()
    
    public var user: Results<User>!
    private let tweets: Tweet
    
    private var replyTweet: [ReplyTweet] = [ReplyTweet]() {
        didSet { collectionView.reloadData() }
    }
    
    private var replies = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Lifecycle

    init(tweets: Tweet){
        self.tweets = tweets
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadData()
    }

    func configureCollectionView(){
        collectionView.backgroundColor = .white
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headeerIdentifier)
    }
    
    public func getTimeStamp(from: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: from)
    }
    
    public func getHeaderTimeStamp(from: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd ・h:mm a "
        return formatter.string(from: from)
    }

}

// MARK: - UICollectionViewDataSource

extension TweetController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.replyTweet.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        cell.delegate = self
        let count = tweets.replyTweet.count
        if indexPath.row < count {
            cell.captionLabel.text = tweets.replyTweet[indexPath.row].replyCaption
        }
        
        let title = NSMutableAttributedString(string: userObject[0].fullname, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(userObject[0].username)", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        title.append(NSAttributedString(string: "・\(self.getTimeStamp(from: tweets.replyTweet[indexPath.row].replyTimeStamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                   .foregroundColor: UIColor.lightGray]))
        
        cell.infoLabel.attributedText = title
        
        if tweets.replyTweet[indexPath.row].didLike == false {
            cell.likeButton.tintColor = .lightGray
            cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        } else {
            cell.likeButton.tintColor = .red
            cell.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension TweetController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headeerIdentifier, for: indexPath) as! TweetHeader
        header.delegate = self
        header.captionLabel.text = tweets.caption
        let dateText = NSAttributedString(string: "・\(self.getHeaderTimeStamp(from: tweets.timestamp))", attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                                                                       .foregroundColor: UIColor.lightGray])
        header.dateLabel.attributedText = dateText
        if tweets.didLike == false {
            header.likeButton.tintColor = .lightGray
            header.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
        } else {
            header.likeButton.tintColor = .red
            header.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
        }
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TweetController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        func size(forWidth width: CGFloat) -> CGSize {
            let measurementLabel = UILabel()
            measurementLabel.numberOfLines = 0
            measurementLabel.text = tweets.caption
            measurementLabel.lineBreakMode = .byWordWrapping
            measurementLabel.translatesAutoresizingMaskIntoConstraints = false
            measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
        let height = size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 170)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweetObject = tweets.replyTweet[indexPath.row]
        func size(forWidth width: CGFloat) -> CGSize {
            let measurementLabel = UILabel()
            measurementLabel.text = tweetObject.replyCaption
            measurementLabel.numberOfLines = 0
            measurementLabel.lineBreakMode = .byWordWrapping
            measurementLabel.translatesAutoresizingMaskIntoConstraints = false
            measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
            return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        }
        let height = size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 100)
    }

}

extension TweetController: TweetHeaderDelegate {
    
    func handleProfileImageTapped(_ header: TweetHeader) {
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ header: TweetHeader) {
        let controller = UploadTweetController(user: user, config: .reply(tweets))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ header: TweetHeader) {
        try! realm.write {
            tweets.didLike.toggle()
            if tweets.didLike == false {
                header.likeButton.tintColor = .lightGray
                header.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                tweets.likes -= 1
                realm.add(tweets, update: .all)
            } else {
                header.likeButton.tintColor = .red
                header.likeButton.setImage(UIImage(named: "baseline_favorite_black_24pt_1x"), for: .normal)
                tweets.likes += 1
                realm.add(tweets, update: .all)
            }
        }
    }
    
    func handleShareTapped(_ header: TweetHeader) {
        let controller = UIActivityViewController(activityItems: [tweets.caption], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
        
}

extension TweetController: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell: TweetCell) {
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        let controller = UploadTweetController(user: user, config: .reply(tweets))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let tweetObject = tweets.replyTweet[indexPath!.row]
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
    
    func handleShareTapped(_ cell: TweetCell) {
        let indexPath = self.collectionView.indexPath(for: cell)
        let tweetObject = tweets.replyTweet[indexPath!.row]
        let controller = UIActivityViewController(activityItems: [tweetObject.replyCaption], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
    }
    
    func deleteActionSheet(_ cell: TweetCell) {
        let alert = UIAlertController(title: "", message: "ツイートを本当に削除しますか？", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "削除する", style: .destructive, handler: { (action: UIAlertAction!) -> Void in
            let indexPath = self.collectionView.indexPath(for: cell)
            let tweetObject = self.tweets.replyTweet[indexPath!.row]
            try! self.realm.write {
                self.realm.delete(tweetObject)
            }
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: nil))
        alert.pruneNegativeWidthConstraints()
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
}
