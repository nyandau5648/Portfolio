//
//  EditProfileController.swift
//  TweetMemo
//
//  Created by Newton on 2020/07/01.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: class {
    func controller(_ controller: EditProfileController, wantsToUpdate user: User)
}

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    
    private var user: Results<User>!
    private lazy var headerView = EditProfileHeader(user: user)
    private let imagePicker = UIImagePickerController()
    private var userInfoChange = false
    private let realm = try! Realm()
    
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var selectedImage: UIImage? {
        didSet {
            headerView.profileImageView.image = selectedImage
        }
    }
    
    // MARK: - Lifecycle
    
    init(user: Results<User>!){
        self.user = user
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureUI()
        configureImagePicker()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Selectors
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone(){
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureNavigationBar(){
        navigationController?.navigationBar.barTintColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationItem.title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
//        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func configureUI(){
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView(frame: .zero)
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        headerView.delegate = self
        self.view.addSubview(headerView)
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func configureImagePicker(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    
}

// MARK - UITableViewDataSource

extension EditProfileController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditProfileCell
        cell.delegate = self
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell}
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        return cell
    }

}

 // MARK - UITableViewDelegate

extension EditProfileController {

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        return option == .profile ? 100 : 48
    }

}

// MARK - EditProfileHeaderDelegate

extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto(){
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK - UIImagePickerControllerDelegate

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        try! self.realm.write {
            let pngData = self.selectedImage?.toPNGData()
            let jpegData = self.selectedImage?.toJPEGData()
            let userResult = self.realm.objects(User.self)
            userResult[0].profileImage = pngData as Data? ?? jpegData as Data?
        }
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK - EditProfileCellDelegate

extension EditProfileController: EditProfileCellDelegate {
    
    func updateUserInfo(_ cell: EditProfileCell) {
        
        guard let viewModel = cell.viewModel else { return }
        userInfoChange = true
        if (cell.infoTextField.text != nil) || cell.profileTextView.text != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        let userResult = self.realm.objects(User.self)
        
        try! realm.write {
            switch viewModel.option {
            case .fullname:
                guard let fullname = cell.infoTextField.text else { return }
                userResult[0].fullname = fullname
                cell.commonInit()
            case .username:
                guard let username = cell.infoTextField.text else { return }
                userResult[0].username = username
                cell.commonInit()
            case .profile:
                guard let profile = cell.profileTextView.text else { return }
                userResult[0].profileText = profile
                cell.commonInit()
            }
        }
    }
    
}
