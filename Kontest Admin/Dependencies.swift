//
//  Dependencies.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Firebase
import Foundation

class Dependencies {
    static let instance = Dependencies()
    
    private init() {
        FirebaseApp.configure()
    }
}
