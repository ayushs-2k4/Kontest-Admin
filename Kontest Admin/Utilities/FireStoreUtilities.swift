//
//  FireStoreUtilities.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseFirestore
import Foundation

class FireStoreUtilities {
    private init() {}

    static let instance = FireStoreUtilities()

    let firestoreEncoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()

        encoder.keyEncodingStrategy = .convertToSnakeCase

        return encoder
    }()

    let firstoreDecoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()

        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()

    // Admins
    let adminsCollection = Firestore.firestore().collection("admins")

    func adminDocument(adminId: String) -> DocumentReference {
        return adminsCollection.document(adminId)
    }

    // Users
    let usersCollection = Firestore.firestore().collection("users")

    func userDocument(userId: String) -> DocumentReference {
        return usersCollection.document(userId)
    }
}
