//
//  InputTextView.swift
//  TweetMemo
//
//  Created by Newton on 2020/07/01.
//  Copyright © 2020 Newton. All rights reserved.
//

import Foundation
import UIKit

class InputTextView: UITextView {
    
    // MARK: - Properties
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What's happening?"
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = true
    
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 4)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
