//
//  Screen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

enum Screen: Hashable {
//    case AllKontestScreen
//    case SettingsScreen
//    case PendingNotificationsScreen

    case HomeScreen
    case SettingsScreen
    case SettingsScreenType(SettingsScreens)
}

enum SettingsScreens: Hashable {
//    case ChangeUserNamesScreen
//    case FilterWebsitesScreen
//    case RotatingMapScreen
    case AuthenticationScreenType(AuthenticationScreens)
}

enum AuthenticationScreens {
    case SignInScreen
    case SignUpScreen
//    case AccountInformationScreen
}
