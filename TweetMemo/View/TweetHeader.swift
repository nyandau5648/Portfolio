//
//  TweetHeader.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/12.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import ActiveLabel
import RealmSwift

private let realm = try! Realm()
private let userObject = realm.objects(User.self)

protocol TweetHeaderDelegate: class {
    func handleProfileImageTapped(_ header: TweetHeader)
    func handleReplyTapped(_ header: TweetHeader)
    func handleLikeTapped(_ header: TweetHeader)
    func handleShareTapped(_ header: TweetHeader)
}

class TweetHeader: UICollectionReusableView {

    // MARK: - Properties
    
    var tweets: Tweet = Tweet() {
        didSet { configure() }
    }
    
    var user: Results<User>!
    
    weak var delegate: TweetHeaderDelegate?

    public lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .twitterBlue
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        return iv
    }()

    public let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    public let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()

    public let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    public let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .left
        return label
    }()

    private lazy var statsView: UIView = {
        let view = UIView()
        
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)
        
        let stack = UIStackView(arrangedSubviews: [commentButton, likeButton, shareButton])
        stack.axis = .horizontal
        stack.spacing = 96
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 60)
        
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1.0)
        
        return view
    }()
    

    public lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "outline_mode_comment_black_24pt_1x")
        button.addTarget(self, action: #selector(handleReplyTapped), for: .touchUpInside)
        return button
    }()

    public lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like_unselected")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()

    public lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "outline_share_black_24pt_1x")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 16)

        let labelStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelStack.axis = .horizontal
        labelStack.spacing = 3

        addSubview(labelStack)
        labelStack.anchor(top: profileImageView.topAnchor, left: profileImageView.rightAnchor, paddingTop: 4, paddingLeft: 16)

        addSubview(captionLabel)
        captionLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)

        addSubview(dateLabel)
        dateLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft:  16)
        
        addSubview(statsView)
        statsView.anchor(top: dateLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12, height: 40)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selector

    @objc func handleProfileImageTapped(){
        delegate?.handleProfileImageTapped(self)
    }

    @objc func handleReplyTapped(){
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(self)
    }

    @objc func handleShareTapped(){
        delegate?.handleShareTapped(self)
    }

    // MARK: - Helper

    func configure(){
        fullnameLabel.text = userObject[0].fullname
        usernameLabel.text = "@" + userObject[0].username
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

}
