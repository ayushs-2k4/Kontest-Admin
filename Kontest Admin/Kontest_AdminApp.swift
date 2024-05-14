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
            ContentView()
                .environment(router)
        }
    }
}
