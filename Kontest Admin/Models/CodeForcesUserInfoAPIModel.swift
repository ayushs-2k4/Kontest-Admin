//
//  CodeForcesUserInfoAPIModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

// MARK: - CodeForcesUserInfoAPIModel

struct CodeForcesUserInfoAPIModel {
    let status: String
    let result: [CodeForcesUserInfoAPIResultModel]
}

// MARK: - CodeForcesUserInfoAPIResultModel

struct CodeForcesUserInfoAPIResultModel {
    let contribution, lastOnlineTimeSeconds, rating, friendOfCount: Int
    let titlePhoto: String
    let rank, handle: String
    let maxRating: Int
    let avatar: String
    let registrationTimeSeconds: Int
    let maxRank: String
}

extension CodeForcesUserInfoAPIModel {
    static func from(dto: CodeForcesUserInfoAPIDTO) -> CodeForcesUserInfoAPIModel {
        let results = dto.result.map { dto in
            userInfoResultDTOToUserInfoAPIResultModel(codeForcesUserInfoAPIResultDTO: dto)
        }
        return CodeForcesUserInfoAPIModel(status: dto.status, result: results)
    }

    private static func userInfoResultDTOToUserInfoAPIResultModel(codeForcesUserInfoAPIResultDTO: CodeForcesUserInfoAPIResultDTO) -> CodeForcesUserInfoAPIResultModel {
        return CodeForcesUserInfoAPIResultModel(contribution: codeForcesUserInfoAPIResultDTO.contribution, lastOnlineTimeSeconds: codeForcesUserInfoAPIResultDTO.lastOnlineTimeSeconds, rating: codeForcesUserInfoAPIResultDTO.rating ?? -1, friendOfCount: codeForcesUserInfoAPIResultDTO.friendOfCount, titlePhoto: codeForcesUserInfoAPIResultDTO.titlePhoto, rank: codeForcesUserInfoAPIResultDTO.rank ?? "-1", handle: codeForcesUserInfoAPIResultDTO.handle, maxRating: codeForcesUserInfoAPIResultDTO.maxRating ?? -1, avatar: codeForcesUserInfoAPIResultDTO.avatar, registrationTimeSeconds: codeForcesUserInfoAPIResultDTO.registrationTimeSeconds, maxRank: codeForcesUserInfoAPIResultDTO.maxRank ?? "-1")
    }
}
