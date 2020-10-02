//
//   EditProfileCell.swift
//  TweetMemo
//
//  Created by Newton on 2020/07/01.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: EditProfileViewModel? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        tf.addTarget(self, action: #selector(handleUpdateUserInfo), for: .editingDidEnd)
        return tf
    }()
    
    let profileTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .twitterBlue
        tv.placeholderLabel.text = "Profile"
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.commonInit()
        
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        titleLabel.contentHuggingPriority(for: NSLayoutConstraint.Axis(rawValue: 750)!)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
        
        self.contentView.addSubview(infoTextField)
        infoTextField.translatesAutoresizingMaskIntoConstraints = false
        infoTextField.contentHuggingPriority(for: NSLayoutConstraint.Axis(rawValue: 750)!)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 16, paddingRight: 8)
    
        self.contentView.addSubview(profileTextView)
        profileTextView.translatesAutoresizingMaskIntoConstraints = false
        profileTextView.contentHuggingPriority(for: NSLayoutConstraint.Axis(rawValue: 750)!)
        profileTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 14, paddingRight: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChange(notification:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: profileTextView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    
    @objc func handleUpdateUserInfo(){
        delegate?.updateUserInfo(self)
    }
    
    @objc func textViewDidChange(notification: NSNotification){
        let maxLength = 100
        let textView = notification.object as! UITextView
        if textView == profileTextView {
            if let text = textView.text {
                var eachCharacter = [Int]()
                for i in 0..<text.count {
                    let textIndex = text.index(text.startIndex, offsetBy: i)
                    eachCharacter.append(String(text[textIndex]).lengthOfBytes(using: String.Encoding.shiftJIS))
                }
                if textView.markedTextRange == nil && text.lengthOfBytes(using: String.Encoding.shiftJIS) > maxLength {
                    var countByte = 0
                    var countCharacter = 0
                    for n in eachCharacter {
                        if countByte < maxLength - 1 {
                            countByte += n
                            countCharacter += 1
                        }
                    }
                    textView.text = text.prefix(countCharacter).description
                }
            }
        }else{
            return
        }
    }
    
    // MARK: - Helpers
    
    func configure(){
        guard let viewModel = viewModel else { return }
        titleLabel.text = viewModel.titleText
        infoTextField.text = viewModel.optionValue
        profileTextView.text = viewModel.optionValue
        switch viewModel.option {
        case .username:
            profileTextView.isHidden = viewModel.shouldHideTextView
        case .fullname:
            profileTextView.isHidden = viewModel.shouldHideTextView
        case .profile:
            infoTextField.isHidden = viewModel.shouldHideTextField
        }
        profileTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholderLabel
    }
    
    public func commonInit(){
        let tools = UIToolbar()
        tools.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.closeButtonTapped))
        tools.items = [spacer, closeButton]
        infoTextField.inputAccessoryView = tools
        profileTextView.inputAccessoryView = tools
    }
    
    @objc func closeButtonTapped(){
        self.endEditing(true)
        self.resignFirstResponder()
    }
    
}
