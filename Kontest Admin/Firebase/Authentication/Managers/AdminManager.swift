//
//  AdminManager.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import OSLog

struct DBAdminUser: Codable {
    let adminId, firstName, lastName, email: String
    let dateCreated: Date

    init(adminId: String, firstName: String, lastName: String, email: String, dateCreated: Date) {
        self.adminId = adminId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.dateCreated = dateCreated
    }
}

final class AdminManager {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "AdminManager")

    static let shared = AdminManager()

    private init() {}

    func createNewAdmin(admin: DBAdminUser) throws {
        try FireStoreUtilities.instance.adminDocument(adminId: admin.adminId).setData(from: admin, merge: false, encoder: FireStoreUtilities.instance.firestoreEncoder)
    }

    func createNewAdmin(auth: AuthDataResultModel, firstName: String, lastName: String) throws {
        try createNewAdmin(
            admin: DBAdminUser(
                adminId: auth.email ?? auth.uid,
                firstName: firstName,
                lastName: lastName,
                email: auth.email ?? "No Email",
                dateCreated: Date()
            )
        )
    }

    func getAdmin(adminId: String) async throws -> DBAdminUser {
        do {
            let snapshot = try await FireStoreUtilities.instance.adminDocument(adminId: adminId).getDocument(as: DBAdminUser.self, decoder: FireStoreUtilities.instance.firstoreDecoder)

            return snapshot
        } catch {
            throw NSError(domain: ErrorDomains.adminNotInDatabase.domain, code: ErrorDomains.adminNotInDatabase.code)
        }
    }
}
