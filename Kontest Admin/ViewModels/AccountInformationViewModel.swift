//
//  AccountInformationViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import Foundation
import OSLog

@Observable
class AccountInformationViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "AccountInformationViewModel")
    
    private init() {
        getAuthenticatedUser()
    }
    
    static let shared = AccountInformationViewModel()
    
    var user: DBAdminUser?
    
    var firstName: String = ""
    var lastName: String = ""
    var fullName: String = ""
    
    var isLoading: Bool = false
    
    func getAuthenticatedUser() {
        if !self.isLoading {
            Task {
                self.isLoading = true
                
                do {
                    let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
                    self.user = try await AdminManager.shared.getAdmin(adminId: authDataResult.email ?? authDataResult.uid)
                    
                    setProperties()
                } catch {
                    logger.log("Error in fetching user: \(error)")
                }
                
                self.isLoading = false
            }
        }
    }
    
    func setProperties() {
        self.firstName = self.user?.firstName ?? ""
        self.lastName = self.user?.lastName ?? ""
        self.fullName = (self.user?.firstName ?? "") + " " + (self.user?.lastName ?? "")
    }
    
    func updateName(firstName: String, lastName: String) {
        AdminManager.shared.updateName(firstName: firstName, lastName: lastName, completion: { error in
            
            if let error {
                print("Error in updating name: \(error)")
                self.logger.log("Error in updating name: \(error)")
                
            } else {
                self.getAuthenticatedUser()
            }
        })
    }
    
    func clearAllFields() {
        self.user = nil
        self.firstName = ""
        self.lastName = ""
        self.fullName = ""
    }
}
