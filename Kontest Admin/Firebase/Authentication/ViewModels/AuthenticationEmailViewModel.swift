//
//  AuthenticationEmailViewModel.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import FirebaseAuth
import Foundation
import OSLog

@Observable
final class AuthenticationEmailViewModel {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "AuthenticationEmailViewModel")

    var email: String = ""
    var password: String = ""

    var isLoading: Bool = false

    var error: Error?

    static let shared = AuthenticationEmailViewModel()

    private init() {}

    func signIn() async -> Bool {
        if email.isEmpty {
            error = AppError(title: "Email cannot be empty.", description: "")
            logger.log("Email is empty.")
            return false
        }

        if password.isEmpty {
            error = AppError(title: "Password cannot be empty.", description: "")
            logger.log("Password is empty.")
            return false
        }

        self.isLoading = true

        do {
            let returnedUserData = try await AuthenticationManager.shared.signIn(email: email, password: password)

            logger.log("Success in logging in with email - password")
            logger.log("returnedUserData: \("\(returnedUserData)")")

            let uid = returnedUserData.email ?? returnedUserData.uid

            let adminData = try await AdminManager.shared.getAdmin(adminId: uid)

            self.isLoading = false
            return true

        } catch {
            let nsError = error as NSError

            if nsError.domain == "FIRAuthErrorDomain" { // checks if error is related to FirebaseAuth
                let errorCode = AuthErrorCode(_nsError: nsError)

                switch errorCode {
                case AuthErrorCode.wrongPassword:
                    self.error = AppError(title: "Your provided password is wrong.", description: "")

                case AuthErrorCode.userDisabled:
                    self.error = AppError(title: "Your Account has been disabled.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.tooManyRequests:
                    self.error = AppError(title: "Your Account has been temporarily disabled due to multiple wrong attempts.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.userNotFound:
                    self.error = AppError(title: "You don't have an account, please Sign up instead!", description: "")

                default:
                    logger.error("\(error)")
                    self.error = error
                }
            } else if nsError.domain == ErrorDomains.adminNotInDatabase.domain // User is present but is not an admin
            {
                do {
                    print("Logged in user which is not present in database, Signing out ...")
                    try AuthenticationManager.shared.signOut()
                    print("Logged out the user successfully which was not in database.")
                } catch {
                    print("Failed to sign out user which is not present in database.")

                    fatalError("Logged in user is not present in database.")
                }
            } else {
                logger.error("\(error)")
                self.error = error
            }

            logger.error("Error in siging in with email - password: \(error)")

            self.isLoading = false
            return false
        }
    }

    func clearAllFields() {
        self.email = ""
        self.password = ""
        self.isLoading = false
        self.error = nil
    }

    func clearPasswordFields() {
        self.password = ""
        self.isLoading = false
        self.error = nil
    }
}

func checkIfEmailIsCorrect(emailAddress: String) -> Bool {
    let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: emailAddress)
}

func checkIfPasswordIsCorrect(password: String) -> Bool {
    // Check if the password is at least 8 characters long
    guard password.count >= 8 else {
        return false
    }

    // Check if the password contains at least one uppercase letter
    let uppercaseLetterRegex = ".*[A-Z]+.*"
    let uppercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
    guard uppercaseLetterTest.evaluate(with: password) else {
        return false
    }

    // Check if the password contains at least one lowercase letter
    let lowercaseLetterRegex = ".*[a-z]+.*"
    let lowercaseLetterTest = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
    guard lowercaseLetterTest.evaluate(with: password) else {
        return false
    }

    // Check if the password contains at least one digit (number)
    let digitRegex = ".*[0-9]+.*"
    let digitTest = NSPredicate(format: "SELF MATCHES %@", digitRegex)
    guard digitTest.evaluate(with: password) else {
        return false
    }

    // All requirements are met
    return true
}