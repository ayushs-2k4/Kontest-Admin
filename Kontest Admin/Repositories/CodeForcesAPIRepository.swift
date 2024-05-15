//
//  CodeForcesAPIRepository.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation
import OSLog

class CodeForcesAPIRepository: CodeForcesFetcher {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeForcesAPIRepository")

    func getUserRating(username: String) async throws -> CodeForcesUserRatingAPIDTO {
        guard let url = URL(string: "https://codeforces.com/api/user.rating?handle=\(username)") else {
            logger.error("Error in making CodeForces ratings url")
            throw URLError(.badURL)
        }

        do {
            let data = try await downloadDataWithAsyncAwait(url: url)
            if String(decoding: data, as: UTF8.self).contains(Constants.codeforcesNotAvailableErrorResponseMessage) {
                throw AppError(title: "CodeForces API not available right now", description: "")
            }

            let fetchedCodeForcesRatings = try JSONDecoder().decode(CodeForcesUserRatingAPIDTO.self, from: data)

            return fetchedCodeForcesRatings
        } catch {
            logger.error("error in downloading CodeForces ratings async await: \(error)")
            throw error
        }
    }

    func getUserInfo(username: String) async throws -> CodeForcesUserInfoAPIDTO {
        guard let url = URL(string: "https://codeforces.com/api/user.info?handles=\(username)") else {
            logger.error("Error in making CodeForces profile url")
            throw URLError(.badURL)
        }

        do {
            let data = try await downloadDataWithAsyncAwait(url: url)

            if String(decoding: data, as: UTF8.self).contains(Constants.codeforcesNotAvailableErrorResponseMessage) {
                throw AppError(title: "CodeForces API not available right now", description: "")
            }

            let fetchedCodeForcesProfile = try JSONDecoder().decode(CodeForcesUserInfoAPIDTO.self, from: data)

            return fetchedCodeForcesProfile
        } catch {
            logger.error("error in downloading CodeForces User Info async await: \(error)")
            throw error
        }
    }
}
