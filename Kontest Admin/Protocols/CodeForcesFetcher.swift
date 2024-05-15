//
//  CodeForcesFetcher.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

protocol CodeForcesFetcher {
    func getUserRating(username: String) async throws -> CodeForcesUserRatingAPIDTO
    func getUserInfo(username: String) async throws -> CodeForcesUserInfoAPIDTO
}
