//
//  CodeForcesUserRatingAPIModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import Foundation

// MARK: - CodeForcesuserRatingAPIModel
/// It will have an arrays of single kontests
struct CodeForcesUserRatingAPIModel: Codable {
    let status: String
    let result: [CodeForcesuserRatingAPIResultModel]
}

// MARK: - CodeForcesuserRatingAPIResultModel
/// Single Codeforces kontest
struct CodeForcesuserRatingAPIResultModel: Codable {
    let contestId: Int
    let contestName: String
    let handle: String
    let rank, ratingUpdateTimeSeconds, oldRating, newRating: Int
    var hasAnimated: Bool = false

    enum CodingKeys: String, CodingKey {
        case contestId
        case contestName, handle, rank, ratingUpdateTimeSeconds, oldRating, newRating
    }
}

extension CodeForcesUserRatingAPIModel {
    static func from(dto: CodeForcesUserRatingAPIDTO) -> CodeForcesUserRatingAPIModel {
        let results = dto.result.map { resultDTO in
            userRatingResultDTOToUserRatingResultModel(codeForcesUserRatingAPIResultDTO: resultDTO)
        }
        return CodeForcesUserRatingAPIModel(status: dto.status, result: results)
    }

    private static func userRatingResultDTOToUserRatingResultModel(codeForcesUserRatingAPIResultDTO: CodeForcesUserRatingAPIResultDTO) -> CodeForcesuserRatingAPIResultModel {
        return CodeForcesuserRatingAPIResultModel(contestId: codeForcesUserRatingAPIResultDTO.contestId, contestName: codeForcesUserRatingAPIResultDTO.contestName, handle: codeForcesUserRatingAPIResultDTO.handle, rank: codeForcesUserRatingAPIResultDTO.rank, ratingUpdateTimeSeconds: codeForcesUserRatingAPIResultDTO.ratingUpdateTimeSeconds, oldRating: codeForcesUserRatingAPIResultDTO.oldRating, newRating: codeForcesUserRatingAPIResultDTO.newRating)
    }
}
