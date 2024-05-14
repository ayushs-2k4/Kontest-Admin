//
//  ContentView.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import SwiftUI

struct ContentView: View {
    let dataViewModel = DataViewModel.instance
    @State private var selectedRow: String?
    @State private var sortOrder = [KeyPathComparator(\DBUser.firstName)]

    var body: some View {
        VStack {
            Table(dataViewModel.users, selection: $selectedRow, sortOrder: $sortOrder) {
                TableColumn("Name") { row in
                    Text(row.firstName + " " + row.lastName)
                }

                TableColumn("College") { row in
                    Text(row.selectedCollege + ", " + row.selectedCollegeState)
                }

                TableColumn("Email", value: \.email, comparator: StringComparator()) { row in
                    Text(row.email)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    try await dataViewModel.getDataOfAllRegisteredUsers()
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(Router.instance)
}
