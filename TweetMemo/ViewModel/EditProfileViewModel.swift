//
//  EditProfileViewModel.swift
//  TweetMemo
//
//  Created by Newton on 2020/07/01.
//  Copyright © 2020 Newton. All rights reserved.
//

import Foundation
import RealmSwift

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case profile

    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "FullName"
        case .profile: return "Profile"
        }
    }
}

struct EditProfileViewModel {

    private let user: Results<User>!
    let option: EditProfileOptions

    var titleText: String {
        return option.description
    }

    var optionValue: String? {
        let realm = try! Realm()
        let userObject = realm.objects(User.self)
        switch option {
        case .username: return userObject[0].username
        case .fullname: return userObject[0].fullname
        case .profile: return userObject[0].profileText
        }
    }

    var shouldHideTextField: Bool {
        return option == .profile
    }

    var shouldHideTextView: Bool {
        return option != .profile
    }

    var shouldHidePlaceholderLabel: Bool {
        let realm = try! Realm()
        let userObject = realm.objects(User.self)
        return userObject[0].profileText != nil
    }

    init(user: Results<User>!, option: EditProfileOptions){
        self.user = user
        self.option = option
    }

}
