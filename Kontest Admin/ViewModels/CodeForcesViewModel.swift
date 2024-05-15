//
//  CodeForcesViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import OSLog
import SwiftUI

struct CodeForcesUserInfo {
    let username: String
    let userInfo: CodeForcesUserInfoAPIModel
    let codeForcesRatings: CodeForcesUserRatingAPIModel
}

@Observable
class CodeForcesViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest", category: "CodeForcesViewModel")
    
    let codeForcesAPIRepository = CodeForcesAPIRepository()
    
    /// Each entry is complete result of a user, so this represents results of all users
    var codeForcesUserInfoAlongWithResults: [CodeForcesUserInfo] = []
    
    var isLoading = false
    
    var attendedKontests: [CodeForcesuserRatingAPIResultModel] = [] {
        didSet {
            print("didSet, oldValue: \(oldValue)")
        }
        
        willSet {
            print("willSet, newValue: \(newValue)")
        }
    }
    
    var error: Error?
    
    var allUserNames: [String] = []
    
    init() {
        self.error = nil
        self.isLoading = true
        
//        if !username.isEmpty {
//            Task {
//                await self.getCodeForcesRatings(username: username)
//                await self.getCodeForcesUserInfo(username: username)
//
//                if let codeForcesRatings {
//                    self.sortedDates = codeForcesRatings.result.map { codeForcesuserRatingAPIResultModel in
//                        let updateTime = codeForcesuserRatingAPIResultModel.ratingUpdateTimeSeconds
//                        let updateDate = Date(timeIntervalSince1970: Double(updateTime))
//
//                        return updateDate
//                    }
//
//                    for result in codeForcesRatings.result {
//                        self.attendedKontests.append(result)
//                    }
//                }
//
//                self.isLoading = false
//            }
//        } else {
//            self.isLoading = false
//        }
    }
    
    private func getCodeForcesRatings(username: String) async throws -> CodeForcesUserRatingAPIModel {
//        do {
//            let fetchedCodeForcesRatings = try await codeForcesAPIRepository.getUserRating(username: username)
        ////            logger.info("\("\(fetchedCodeForcesRatings)")")
//
//            codeForcesRatings = CodeForcesUserRatingAPIModel.from(dto: fetchedCodeForcesRatings)
//        } catch {
//            self.error = error
//            logger.error("error in fetching CodeForces Rating: \(error)")
//        }
        
        let fetchedCodeForcesRatings = try await codeForcesAPIRepository.getUserRating(username: username)
            
        return CodeForcesUserRatingAPIModel.from(dto: fetchedCodeForcesRatings)
    }
    
    private func getCodeForcesUserInfo(username: String) async throws -> CodeForcesUserInfoAPIModel {
//        do {
//            let fetchedCodeForcesUserInfo = try await codeForcesAPIRepository.getUserInfo(username: username)
        ////            logger.info("\("\(fetchedCodeForcesUserInfo)")")
//
//            codeForcesUserInfos = CodeForcesUserInfoAPIModel.from(dto: fetchedCodeForcesUserInfo)
//        } catch {
//            self.error = error
//            logger.error("error in fetching CodeForces User Info: \(error)")
//        }
        
        let fetchedCodeForcesUserInfo = try await codeForcesAPIRepository.getUserInfo(username: username)
            
        return CodeForcesUserInfoAPIModel.from(dto: fetchedCodeForcesUserInfo)
    }
    
    func updateUserNames(newUserNames: [String]) {
        self.allUserNames = newUserNames
        
        self.attendedKontests.removeAll(keepingCapacity: true)
        
        Task {
            let k = await self.getInfoForMultipleUsers(usernames: allUserNames)
            
            self.codeForcesUserInfoAlongWithResults = k
        }
    }
    
    func getCompleteInformationOfAUser(username: String) async -> CodeForcesUserInfo? {
        do {
            let codeForcesProfile: CodeForcesUserInfoAPIModel = try await getCodeForcesUserInfo(username: username)
            
            let codeForcesRatings: CodeForcesUserRatingAPIModel = try await getCodeForcesRatings(username: username)
            
            return CodeForcesUserInfo(username: username, userInfo: codeForcesProfile, codeForcesRatings: codeForcesRatings)
        } catch {
            print("Error in fetching codeforcesUserInfo for username: \(username) with error: \(error)")
            
            return nil
        }
    }
    
    func getInfoForMultipleUsers(usernames: [String]) async -> [CodeForcesUserInfo] {
        var codeForcesUserInfos: [CodeForcesUserInfo] = []
        
        for username in usernames {
            if let codeForcesUserInfo = await getCompleteInformationOfAUser(username: username) {
                codeForcesUserInfos.append(codeForcesUserInfo)
            }
        }
        
        return codeForcesUserInfos
    }
}

extension CodeForcesViewModel {
    private func getRatingsTitle(codeForcesRating: CodeForcesUserRatingAPIModel) -> (title: String, color: Color) {
        let newRating = codeForcesRating.result[codeForcesRating.result.count - 1].newRating

        return if newRating <= 1199 {
            ("N e w b i e".uppercased(), .white)
        } else if newRating <= 1399 {
            ("P u p i l".uppercased(), .green.opacity(0.5))
        } else if newRating <= 1599 {
            ("S p e c i a l i s t".uppercased(), .cyan)
        } else if newRating <= 1899 {
            ("E x p e r t".uppercased(), .blue)
        } else if newRating <= 2199 {
            ("Candidate Master".uppercased(), Color(red: 255/255, green: 85/255, blue: 254/255))
        } else if newRating <= 2299 {
            ("M a s t e r".uppercased(), .orange)
        } else if newRating <= 2399 {
            ("International Master".uppercased(), .orange)
        } else if newRating <= 2599 {
            ("Grandmaster".uppercased(), .red)
        } else if newRating <= 2899 {
            ("International Grandmaster".uppercased(), .red)
        } else {
            ("Legendary Grandmaster".uppercased(), .red)
        }
    }
}
