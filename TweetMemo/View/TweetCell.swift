//
//  TweetCell.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/09.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift
import ActiveLabel

protocol TweetCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleShareTapped(_ cell: TweetCell)
    func deleteActionSheet(_ cell: TweetCell)
}

private let realm = try! Realm()
private let userObject = Array(realm.objects(User.self))
private let tweetObject = Array(realm.objects(Tweet.self))

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var tweets: Tweet = Tweet() {
        didSet { configure() }
    }
    
    var replyTweets: ReplyTweet = ReplyTweet() {
        didSet { configure() }
    }
    
    private var user: Results<User>!
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(named: "placeholderImg")
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.mentionColor = .twitterBlue
        return label
    }()
    
    public let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    public lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "outline_mode_comment_black_24pt_1x"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    public lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.tintColor = .lightGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    public lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "outline_share_black_24pt_1x"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_keyboard_arrow_down_black_24pt_1x-1"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        return button
    }()
    
    public let infoLabel = UILabel()
    
    var usernameText: String {
        return "@\(userObject[0].username)"
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        
        let stack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingRight: 12)
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, likeButton, shareButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 96
        
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(top: stack.bottomAnchor,bottom: bottomAnchor, paddingTop: 8, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 1)
        
        addSubview(optionButton)
        optionButton.anchor(top: topAnchor, right: stack.rightAnchor, paddingTop: 8, paddingRight: 8)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selecter
    
    @objc func handleProfileImageTapped(){
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped(){
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped(){
        delegate?.handleShareTapped(self)
    }
    
    @objc func showActionSheet(){
        delegate?.deleteActionSheet(self)
    }
    
    // MARK: - Helper
    
    public func configure(){
        if userObject[0].profileImage != nil {
            self.profileImageView.image = UIImage(data: userObject[0].profileImage!)
        } else {
            profileImageView.image = UIImage(named: "placeholderImg")
        }
    }
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
    
    func size(_ cell: TweetCell,forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
}
