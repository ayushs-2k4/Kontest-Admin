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

    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var uid: String = ""

    var isLoading: Bool = false

    var error: Error?

    var showMakeAdminDialog: Bool = false

    static let shared = AuthenticationEmailViewModel()

    let shouldEnableMakingExistingUserAsAdmin: Bool = false
    // for making current notAdmin user admin
    var notAdminUserId: String = ""
    var notAdminUserFirstName: String = ""
    var notAdminUserLastName: String = ""
    var notAdminUserEmail: String = ""
    var notAdminUserDateCreated: Date = .now

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
            self.uid = uid
            let _ = try await AdminManager.shared.getAdmin(adminId: uid) // so that we can throw "adminNotInDatabase" error.

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
                    self.error = AppError(title: "You are not an admin", description: "Please sign in via admin account. To make an admin account, \ncontact Support - ayushsinghals02@gmail.com")
                    print("Logged in user which is not present in database, Signing out ...")

                    // for making current notAdmin user admin
                    if shouldEnableMakingExistingUserAsAdmin {
                        let loggedInPersonData = try await FireStoreUtilities.instance.userDocument(userId: uid).getDocument(as: DBUser.self, decoder: FireStoreUtilities.instance.firstoreDecoder)
                        notAdminUserId = loggedInPersonData.userId
                        notAdminUserFirstName = loggedInPersonData.firstName
                        notAdminUserLastName = loggedInPersonData.lastName
                        notAdminUserEmail = loggedInPersonData.email
                        notAdminUserDateCreated = loggedInPersonData.dateCreated
                        showMakeAdminDialog = true
                    }

                    try AuthenticationManager.shared.signOut()
                    print("Logged out the user successfully which was not in database.")
                } catch {
                    print("Failed to sign out user which is not present in database, error: \(error)")

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

    func signUp() async -> Bool {
        isLoading = true

        guard !email.isEmpty,!password.isEmpty else {
            error = AppError(title: "Email or Password is Empty", description: "")
            logger.error("No email or password found.")
            return false
        }

        do {
            let returnedUserData = try await AuthenticationManager.shared.createNewUser(email: email, password: password)
            logger.log("Success in signing up with email - password")
            logger.log("returnedUserData: \("\(returnedUserData)")")

            self.isLoading = false

            try AdminManager.shared.createNewAdmin(
                auth: returnedUserData,
                firstName: self.firstName,
                lastName: self.lastName
            )

            return true
        } catch {
            let nsError = error as NSError

            if nsError.domain == "FIRAuthErrorDomain" { // checks if error is related to FirebaseAuth
                let errorCode = AuthErrorCode(_nsError: nsError)

                switch errorCode {
                case AuthErrorCode.userDisabled:
                    self.error = AppError(title: "Your Account has been disabled.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.tooManyRequests:
                    self.error = AppError(title: "Your Account has been temporarily disabled due to multiple wrong attempts.", description: "Contact Support - ayushsinghals02@gmail.com")

                case AuthErrorCode.invalidEmail:
                    self.error = AppError(title: "Email is in invalid format.", description: "Please provide a valid email address.")

                case AuthErrorCode.emailAlreadyInUse:
                    self.error = AppError(title: "Email is already in use.", description: "Please use a different email address or sign in.")

                case AuthErrorCode.weakPassword:
                    self.error = AppError(title: "Password is weak.", description: "Your password must be at least 6 characters long.")

                case AuthErrorCode.operationNotAllowed:
                    self.error = AppError(title: "Signup is currently Not Allowed.", description: "Email/password signup is disabled for these credentials.")

                default:
                    logger.error("\(error)")
                    self.error = error
                }
            } else {
                logger.error("\(error)")
                self.error = error
            }

            logger.error("Error in siging up with email - password: \(error)")

            self.isLoading = false
            return false
        }
    }

    func clearAllFields() {
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.firstName = ""
        self.lastName = ""
        self.isLoading = false
        self.error = nil
    }

    func clearPasswordFields() {
        self.password = ""
        self.confirmPassword = ""
        self.isLoading = false
        self.error = nil
    }

    // for making current notAdmin user admin
    func makeExistingUserAdmin() {
        do {
            try AdminManager.shared.createNewAdmin(
                admin: DBAdminUser(
                    adminId: notAdminUserId,
                    firstName: notAdminUserFirstName,
                    lastName: notAdminUserLastName,
                    email: notAdminUserEmail,
                    dateCreated: notAdminUserDateCreated
                )
            )
        } catch {}
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
