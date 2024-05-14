//
//  SignInScreen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 14/05/24.
//

import SwiftUI
import OSLog

struct SignInScreen: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "SignInScreen")
    
    let authenticationEmailViewModel: AuthenticationEmailViewModel = .shared

    @State private var isPasswordFieldVisible: Bool = false

    @FocusState private var focusedField: SignInTextField?

    @Environment(Router.self) private var router

    var body: some View {
        VStack {
            SignInViewTextField(
                leftText: "Email ID:",
                textHint: "Email",
                isPasswordType: false,
                focusedField: _focusedField,
                currentField: .email,
                textBinding: Bindable(authenticationEmailViewModel).email
            )
            .padding(.horizontal)

            if isPasswordFieldVisible {
                SignInViewTextField(
                    leftText: "Password:",
                    textHint: "required",
                    isPasswordType: true,
                    focusedField: _focusedField,
                    currentField: .password,
                    textBinding: Bindable(authenticationEmailViewModel).password
                )
                .padding(.horizontal)
            }

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
                    router.appendScreen(screen: Screen.SettingsScreenType(.AuthenticationScreenType(.SignUpScreen)))
                } label: {
                    Text("Sign Up Instead")
                }

                Button("Continue") {
                    authenticationEmailViewModel.error = nil

                    if !isPasswordFieldVisible { // only email field is visible
                        if authenticationEmailViewModel.email.isEmpty {
                            authenticationEmailViewModel.error = AppError(title: "Email can not be empty.", description: "")
                        } else if !checkIfEmailIsCorrect(emailAddress: authenticationEmailViewModel.email) {
                            authenticationEmailViewModel.error = AppError(title: "Email is not in correct format.", description: "")
                        } else {
                            isPasswordFieldVisible = true

                            self.focusedField = .password
                        }

                    } else {
                        Task {
                            let isSignInSuccessful = await authenticationEmailViewModel.signIn()

                            if isSignInSuccessful {
                                logger.log("Yes, sign in is successful")

                                router.goToRootView()

                                authenticationEmailViewModel.clearAllFields()
                            } else {
                                logger.log("No, sign in is not successful")
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .keyboardShortcut(.return, modifiers: [])
            }

            .padding(.horizontal)
        }
        .onAppear {
            self.focusedField = .email
        }
        #if os(macOS)
        .frame(maxWidth: 400)
        #endif
    }
}

private struct SignInViewTextField: View {
    let leftText: String
    let textHint: String
    var isPasswordType: Bool = false
    @FocusState private var focusedField: SignInTextField?
    let currentField: SignInTextField
    @Binding var textBinding: String

    init(
        leftText: String,
        textHint: String,
        isPasswordType: Bool,
        focusedField: FocusState<SignInTextField?>,
        currentField: SignInTextField,
        textBinding: Binding<String>
    ) {
        self.leftText = leftText
        self.textHint = textHint
        self.isPasswordType = isPasswordType
        self._focusedField = focusedField
        self.currentField = currentField
        self._textBinding = textBinding
    }

    var body: some View {
        HStack {
            Text(leftText)

            if isPasswordType {
                SecureField(textHint, text: $textBinding)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: currentField)
            } else {
                TextField(textHint, text: $textBinding)
                    .multilineTextAlignment(.trailing)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: currentField)
            }
        }
        .padding(10)
        .overlay( // apply a rounded border
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(.systemGray), lineWidth: 1)
        )
    }
}

enum SignInTextField {
    case email
    case password
}

#Preview {
    SignInScreen()
        .environment(Router.instance)
        .frame(width: 500, height: 500)
}
