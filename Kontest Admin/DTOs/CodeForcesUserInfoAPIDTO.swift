//
//  CodeForcesUserInfoAPIDTO.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

// MARK: - CodeForcesUserInfoDTO

struct CodeForcesUserInfoAPIDTO: Codable {
    let status: String
    let result: [CodeForcesUserInfoAPIResultDTO]
}

// MARK: - CodeForcesUserInfoAPIResultDTO

struct CodeForcesUserInfoAPIResultDTO: Codable {
    let contribution, lastOnlineTimeSeconds, friendOfCount: Int
    let titlePhoto: String
    let handle: String
    let avatar: String
    let registrationTimeSeconds: Int

    let rating, maxRating: Int? // Making optional, because when user has not given any contest, then these do not come in JSON from API.
    let rank, maxRank: String? // Making optional, because when user has not given any contest, then these do not come in JSON from API.
}
