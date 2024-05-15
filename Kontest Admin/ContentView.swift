//
//  ContentView.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    @Environment(Router.self) private var router

    var body: some View {
        if AuthenticationManager.shared.isSignedIn() {
            AllUsersView()
        } else {
            SignInScreen()
        }
    }
}

#Preview {
    ContentView()
}
