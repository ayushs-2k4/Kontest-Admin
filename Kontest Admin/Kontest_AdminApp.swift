//
//  Kontest_AdminApp.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import SwiftUI

@main

struct Kontest_AdminApp: App {
    let dependencies = Dependencies.instance

    @State private var router = Router.instance

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: Bindable(router).path) {
                ContentView()
                    .navigationDestination(for: SelectionState.self) { selectionState in
                        switch selectionState {
                        case .screen(let screen):
                            switch screen {
                            case .HomeScreen:
                                AllUsersView()

                            case .SettingsScreen:
                                SettingsScreen()

                            case .SettingsScreenType(let settingsScreenType):
                                switch settingsScreenType {
                                case .AuthenticationScreenType(let authenticationScreenType):
                                    switch authenticationScreenType {
                                    case .SignInScreen:
                                        SignInScreen()

                                    case .SignUpScreen:
                                        SignUpScreen()

                                    case .AccountInformationScreen:
                                        AccountInformationScreen()
                                    }

                                case .RotatingMapScreen:
                                    RandomRotatingMapScreen(navigationTitle: "About Me")
                                }
                            }
                        }
                    }
            }
        }
        .commands {
            MyMenu(router: $router)
        }
    }
}
