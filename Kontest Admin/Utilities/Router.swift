//
//  Router.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation
import OSLog

enum SelectionState: Hashable {
    case screen(Screen)
}

@Observable
class Router {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "Router")

    var path = [SelectionState]() {
        didSet {
            logger.info("path: \(self.path)")
            logger.info("currentSelectionState: \("\(self.path.last)")")
        }
    }

    var currentSelectionState: SelectionState = .screen(.HomeScreen)
    private init() {}

    func appendScreen(screen: Screen) {
        if screen == .SettingsScreen, path.contains(.screen(.SettingsScreen)) {
        } else {
            path.append(SelectionState.screen(screen))
        }
    }

    func popLastScreen() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func goToRootView() {
        path.removeAll()
    }

    static let instance: Router = .init()
}
