//
//  AppError.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

struct AppError: Error, LocalizedError {
    let title: String
    let description: String

    let actionLabel: String
    let action: (() -> Void)?

    init(title: String, description: String) {
        self.title = title
        self.description = description
        self.action = nil
        self.actionLabel = ""
    }

    init(title: String, description: String, action: @escaping (() -> Void), actionLabel: String) {
        self.title = title
        self.description = description
        self.action = action
        self.actionLabel = actionLabel
    }

    var errorDescription: String? { description }
}
