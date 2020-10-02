//
//  EditProfileHeader.swift
//  TweetMemo
//
//  Created by Newton on 2020/07/01.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

protocol EditProfileHeaderDelegate: class {
    func didTapChangeProfilePhoto()
}

class EditProfileHeader: UIView {
    
    // MARK: - Properties
    
    private let user: Results<User>!
    weak var delegate: EditProfileHeaderDelegate?
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "placeholderImg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 3.0
        iv.layer.masksToBounds = true
        return iv
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Profile Photo", for: .normal)
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    init(user: Results<User>!){
        self.user = user
        super.init(frame: .zero)
        
        isUserInteractionEnabled = true
        
        backgroundColor = .twitterBlue
        
        addSubview(profileImageView)
        profileImageView.center(inView: self, yConstant: -16)
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        
        self.configure()
        
        addSubview(changePhotoButton)
        changePhotoButton.centerX(inView: self, topAnchor: profileImageView.bottomAnchor, paddingTop: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleChangeProfilePhoto(){
        delegate?.didTapChangeProfilePhoto()
    }
    
    func configure(){
        let realm = try! Realm()
        try! realm.write {
            let userObject = realm.objects(User.self)
            if userObject[0].profileImage != nil {
                profileImageView.image = UIImage(data: userObject[0].profileImage!)
            } else {
                profileImageView.image = UIImage(named: "placeholderImg")
            }
        }
    }
 
    
}
