//
//  ViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import Foundation
import OSLog

struct OneUserData: Identifiable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let email: String
    let selectedCollege: String
    let selectedCollegeState: String
    let codeForcesUsername, codeChefUsername, leetcodeUsername: String
    let codeForcesRating, codeChefRating, leetcodeRating: Float

    var fullName: String {
        firstName + " " + lastName
    }

    var fullCollegeName: String {
        selectedCollege + ", " + selectedCollegeState
    }
}

@Observable
class ViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "ViewModel")

    private init() {
        Task {
            do {
                try await dataViewModel.getDataOfAllRegisteredUsers()

                for user in dataViewModel.users {
                    self.finalData.append(
                        OneUserData(
                            firstName: user.firstName,
                            lastName: user.lastName,
                            email: user.email,
                            selectedCollege: user.selectedCollege,
                            selectedCollegeState: user.selectedCollegeState,
                            codeForcesUsername: user.codeForcesUsername,
                            codeChefUsername: user.codeChefUsername,
                            leetcodeUsername: user.leetcodeUsername,
                            codeForcesRating: user.codeForcesRating,
                            codeChefRating: user.codeChefRating,
                            leetcodeRating: user.leetcodeRating
                        )
                    )
                }
            }
            catch {
                logger.error("Not able to download data of users, error: \(error)")
            }
        }
    }

    static let instance = ViewModel()

    let dataViewModel = DataViewModel.instance

    var finalData: [OneUserData] = []
}
