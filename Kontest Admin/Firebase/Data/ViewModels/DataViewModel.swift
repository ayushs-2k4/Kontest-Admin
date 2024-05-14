//
//  DataViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import Foundation

struct DBUser: Codable, Identifiable {
    var id: String { userId }

    let userId, firstName, lastName, email, selectedCollegeState, selectedCollege, leetcodeUsername, codeForcesUsername, codeChefUsername: String
    let dateCreated: Date

    init(userId: String, firstName: String, lastName: String, email: String, selectedCollegeState: String, selectedCollege: String, leetcodeUsername: String, codeForcesUsername: String, codeChefUsername: String, dateCreated: Date) {
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
    static let instance = DataViewModel()

    var users: [DBUser] = []

    private init() {}

    private let usersCollection = Firestore.firestore().collection("users")

    func getDataOfAllRegisteredUsers() async throws {
        let allUsers = try await FireStoreUtilities.instance.usersCollection.getDocuments()

        for user in allUsers.documents {
            do {
                let decodedUser = try user.data(as: DBUser.self, decoder: FireStoreUtilities.instance.firstoreDecoder)

                users.append(decodedUser)
            } catch {
                print("Not able to decode user with error: \(error)")
            }
        }
    }
}