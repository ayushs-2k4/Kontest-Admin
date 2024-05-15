//
//  SignUpScreen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import SwiftUI

struct SignUpScreen: View {
    let authenticationEmailViewModel: AuthenticationEmailViewModel = .shared

    @Environment(Router.self) private var router

    @FocusState private var focusedField: SignUpTextField?

    @State private var isCollegeListDownloading = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Get started with your name, email address and password.")
                .bold()
                .padding(.bottom)

            HStack {
                Text("             Name:")

                TextField("first", text: Bindable(authenticationEmailViewModel).firstName)
                    .focused($focusedField, equals: .firstName)

                TextField("last", text: Bindable(authenticationEmailViewModel).lastName)
                    .focused($focusedField, equals: .lastName)
            }

            HStack {
                Text("Email address:")

                TextField("name@example.com", text: Bindable(authenticationEmailViewModel).email)
                    .focused($focusedField, equals: .email)
                #if available
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                #endif
            }
            .padding(.vertical)

            HStack(alignment: .top) {
                Text("       Password:")

                VStack(alignment: .leading) {
                    SecureField("required", text: Bindable(authenticationEmailViewModel).password)
                        .focused($focusedField, equals: .password)

                    SecureField("verify", text: Bindable(authenticationEmailViewModel).confirmPassword)
                        .focused($focusedField, equals: .confirmPassword)

                    Text("Your password must be at least 8 characters long and include a number, an uppercase letter and a lowercase letter.")
                }
            }
            .padding(.vertical)

            if let error = authenticationEmailViewModel.error {
                HStack {
                    Spacer()

                    if let appError = error as? AppError {
                        VStack(alignment: .trailing) {
                            Text(appError.title)
                                .foregroundStyle(.red)
                                .padding(.horizontal)

                            if !appError.description.isEmpty {
                                Text(appError.description)
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
            }

            HStack {
                Spacer()

                if authenticationEmailViewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.horizontal, 1)
                }

                Button {
                    authenticationEmailViewModel.clearPasswordFields()
                    router.popLastScreen()
                    router.appendScreen(screen: Screen.SettingsScreenType(.AuthenticationScreenType(.SignInScreen)))
                } label: {
                    Text("Sign In Instead")
                }

                Button {
                    authenticationEmailViewModel.error = nil

                    authenticationEmailViewModel.firstName = authenticationEmailViewModel.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    authenticationEmailViewModel.lastName = authenticationEmailViewModel.lastName.trimmingCharacters(in: .whitespacesAndNewlines)

                    if authenticationEmailViewModel.firstName.isEmpty {
                        authenticationEmailViewModel.error = AppError(title: "First name can not be empty.", description: "")
                    } else if authenticationEmailViewModel.lastName.isEmpty {
                        authenticationEmailViewModel.error = AppError(title: "Last name can not be empty.", description: "")
                    } else if authenticationEmailViewModel.email.isEmpty {
                        authenticationEmailViewModel.error = AppError(title: "Email can not be empty.", description: "")
                    } else if !checkIfEmailIsCorrect(emailAddress: authenticationEmailViewModel.email) {
                        authenticationEmailViewModel.error = AppError(title: "Email is not in correct format.", description: "")
                    } else if authenticationEmailViewModel.password.isEmpty {
                        authenticationEmailViewModel.error = AppError(title: "Password can not be empty.", description: "")
                    } else if !checkIfPasswordIsCorrect(password: authenticationEmailViewModel.password) {
                        authenticationEmailViewModel.error = AppError(title: "Password not complying with requirements.", description: "")
                    } else if authenticationEmailViewModel.password != authenticationEmailViewModel.confirmPassword {
                        authenticationEmailViewModel.error = AppError(title: "The passwords you entered do not match.", description: "")
                    } else {
                        Task {
                            let isSignUpSuccessful = await authenticationEmailViewModel.signUp()

                            if isSignUpSuccessful {
                                print("Yes, sign up is successful")

                                router.goToRootView()

                                authenticationEmailViewModel.clearAllFields()
                            } else {
                                print("No, sign up is not successful")
                            }
                        }
                    }
                } label: {
                    Text("Sign Up")
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(false)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .navigationTitle("Sign Up")
        #if os(macOS)
        .frame(maxWidth: 400)
        #endif
        .padding()
        .onAppear {
            self.focusedField = .firstName
        }
        .onChange(of: focusedField) { oldValue, newValue in
            print("Focus Changed from \(String(describing: oldValue)) to \(String(describing: newValue))")

            authenticationEmailViewModel.firstName = authenticationEmailViewModel.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            authenticationEmailViewModel.lastName = authenticationEmailViewModel.lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

enum SignUpTextField {
    case firstName
    case lastName
    case email
    case password
    case confirmPassword
}

#Preview {
    SignUpScreen()
        .environment(Router.instance)
        .frame(width: 400, height: 400)
}
