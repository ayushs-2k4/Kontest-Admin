//
//  AllUsersView.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import SwiftUI

struct AllUsersView: View {
    let dataViewModel = DataViewModel.instance
    @State private var selectedRow: UUID?
    @State private var sortOrder = [KeyPathComparator(\OneUserData.fullName)]
    let viewModel: ViewModel = .instance
    @State private var router = Router.instance

    var body: some View {
        Table(viewModel.finalData, selection: $selectedRow, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.fullName)

            TableColumn("Email", value: \.email)

            TableColumn("College", value: \.fullCollegeName)

            TableColumn("CodeForces Rating - username", value: \.codeForcesRating) { row in
                Text("\(Int(row.codeForcesRating)) - \(row.codeForcesUsername)")
            }

            TableColumn("CodeChef Rating - username", value: \.codeChefRating) { row in
                Text("\(Int(row.codeChefRating)) - \(row.codeChefUsername)")
            }

            TableColumn("LeetCode Rating - username", value: \.leetcodeRating) { row in
                Text("\(Int(row.leetcodeRating)) - \(row.leetcodeUsername)")
            }
        }
        .navigationTitle("Data of Students")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    router.appendScreen(screen: .SettingsScreen)
                } label: {
                    Image(systemName: "gear")
                }
                .help("Settings") // Tooltip text
            }
        }
        .onChange(of: sortOrder) {
            viewModel.finalData.sort(using: sortOrder)
        }
    }
}

#Preview {
    AllUsersView()
}
