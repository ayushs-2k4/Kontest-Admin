//
//  Screen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

enum Screen: Hashable {
    case HomeScreen
    case SettingsScreen
    case SettingsScreenType(SettingsScreens)
}

enum SettingsScreens: Hashable {
//    case ChangeUserNamesScreen
//    case FilterWebsitesScreen
    case AuthenticationScreenType(AuthenticationScreens)
    case RotatingMapScreen
}

enum AuthenticationScreens {
    case SignInScreen
    case SignUpScreen
    case AccountInformationScreen
}
