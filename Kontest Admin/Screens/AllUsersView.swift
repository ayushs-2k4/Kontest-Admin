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

    @SceneStorage("AllUsersTableTableConfig")
    private var columnCustomization: TableColumnCustomization<OneUserData>

    var body: some View {
        Table(
            viewModel.finalData,
            selection: $selectedRow,
            sortOrder: $sortOrder,
            columnCustomization: $columnCustomization
        ) {
            TableColumn("Name", value: \.fullName)
                .customizationID("Name")

            TableColumn("Email", value: \.email)
                .customizationID("Email")

            TableColumn("College", value: \.fullCollegeName)
                .customizationID("College")

            TableColumn("CodeForces Rating - username", value: \.codeForcesRating) { row in
                Text("\(Int(row.codeForcesRating)) - \(row.codeForcesUsername)")
            }
            .customizationID("CodeForces")

            TableColumn("CodeChef Rating - username", value: \.codeChefRating) { row in
                Text("\(Int(row.codeChefRating)) - \(row.codeChefUsername)")
            }
            .customizationID("CodeChef")

            TableColumn("LeetCode Rating - username", value: \.leetcodeRating) { row in
                Text("\(Int(row.leetcodeRating)) - \(row.leetcodeUsername)")
            }
            .customizationID("LeetCode")
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
