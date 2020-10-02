//
//  CaptionTextView.swift
//  TweetMemo
//
//  Created by Newton on 2020/05/09.
//  Copyright © 2020 Newton. All rights reserved.
//

import UIKit

class CaptionTextView: UITextView {
    
    // MARK: - Properties
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What happend?"
        return label
    }()
    
    // MARK : - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 4)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selecter
    
    @objc func handleTextInputChange(){
        if text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
    
}
