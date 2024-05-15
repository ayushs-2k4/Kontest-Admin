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
    
    private(set) var codeForcesViewModel: CodeForcesViewModel
    
    private init() {
        FirebaseApp.configure()
        
        self.codeForcesViewModel = CodeForcesViewModel()
    }
    
    
}
