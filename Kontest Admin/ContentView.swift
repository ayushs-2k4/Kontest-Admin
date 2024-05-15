//
//  ContentView.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import SwiftUI

struct ContentView: View {
    @State private var router = Router.instance
    private var bgColors: [Color] = [.indigo, .yellow, .green, .orange, .brown]

    @State private var path: [SelectionState] = []

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
