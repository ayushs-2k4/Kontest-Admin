//
//  DataViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import Foundation
import OSLog

struct DBUser: Codable, Identifiable, Equatable {
    var id: String { userId }

    let userId, firstName, lastName, email, selectedCollegeState, selectedCollege, leetcodeUsername, codeForcesUsername, codeChefUsername: String
    let dateCreated: Date
    let codeForcesRating, codeChefRating, leetcodeRating: Float

    init(userId: String, firstName: String, lastName: String, email: String, selectedCollegeState: String, selectedCollege: String, leetcodeUsername: String, codeForcesUsername: String, codeChefUsername: String, dateCreated: Date, codeForcesRating: Float, codeChefRating: Float, leetcodeRating: Float) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.selectedCollegeState = selectedCollegeState
        self.selectedCollege = selectedCollege
        self.leetcodeUsername = leetcodeUsername
        self.codeForcesUsername = codeForcesUsername
        self.codeChefUsername = codeChefUsername
        self.dateCreated = dateCreated
        self.codeForcesRating = codeForcesRating
        self.codeChefRating = codeChefRating
        self.leetcodeRating = leetcodeRating
    }
}

struct StringComparator: SortComparator {
    var order: SortOrder = .forward
    func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
        return if lhs <= rhs {
            .orderedAscending
        } else {
            .orderedDescending
        }
    }
}

extension ComparisonResult {
    var reversed: ComparisonResult {
        switch self {
        case .orderedAscending: return .orderedDescending
        case .orderedSame: return .orderedSame
        case .orderedDescending: return .orderedAscending
        }
    }
}

@Observable
class DataViewModel {
    let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "DataViewModel")
    static let instance = DataViewModel()

    var users: [DBUser] = []

    private init() {}

    private let usersCollection = Firestore.firestore().collection("users")

    func getDataOfAllRegisteredUsers() async throws {
        let allUsers = try await FireStoreUtilities.instance.usersCollection.getDocuments()
        print("YES")
        var downloadedUsers: [DBUser] = []

        logger.log("allUsers: \(allUsers)")

        for user in allUsers.documents {
            logger.log("user: \(user.data())")

            do {
                let decodedUser = try user.data(as: DBUser.self, decoder: FireStoreUtilities.instance.firstoreDecoder)

                logger.log("decodedUser: \("\(decodedUser)")")

                downloadedUsers.append(decodedUser)
            } catch {
                logger.log("Not able to decode user with error: \(error)")
            }
        }

        self.users = downloadedUsers
    }
}
