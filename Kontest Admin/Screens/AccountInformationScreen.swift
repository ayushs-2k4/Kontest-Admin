//
//  AccountInformationScreen.swift
//  Kontest Admin
//
//  Created by Ayush Singhal on 15/05/24.
//

import OSLog
import SwiftUI

struct AccountInformationScreen: View {
    private let logger = Logger(subsystem: "com.ayushsinghal.Kontest-Admin", category: "AccountInformationScreen")
    
    @State private var router = Router.instance
    
    let accountInformationViewModel = AccountInformationViewModel.shared
    @State private var isAuthenticated: Bool = AuthenticationManager.shared.isSignedIn()
    
    @State private var isNameChangeSheetPresented: Bool = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Name")
                    
                    Spacer()
                    
                    Text(accountInformationViewModel.fullName)
                }
                .onTapGesture(perform: {
                    if !accountInformationViewModel.isLoading {
                        isNameChangeSheetPresented = true
                    }
                })
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray)
                    .padding(1)
            }
            
            Button("Sign Out") {
                do {
                    try AuthenticationManager.shared.signOut()
                    
                    accountInformationViewModel.clearAllFields()
                    
                    router.goToRootView()
                } catch {
                    logger.log("Error in Signing out: \(error)")
                }

                isAuthenticated = AuthenticationManager.shared.isSignedIn()
            }
            
            if accountInformationViewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .hidden()
            }
        }
        .onAppear(perform: {
            if accountInformationViewModel.user == nil {
                accountInformationViewModel.getAuthenticatedUser()
            }
        })
        .padding()
        .frame(maxWidth: 400)
        .sheet(isPresented: $isNameChangeSheetPresented, content: {
            ChangeNameSheetView()
                .frame(minWidth: 400)
                .padding()
        })
    }
}

struct ChangeNameSheetView: View {
    let accountInformationViewModel = AccountInformationViewModel.shared
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var firstName: String
    @State private var lastName: String
    
    @State private var isFirstNameErrorShown: Bool = false
    @State private var isLastNameErrorShown: Bool = false
    
    init() {
        self._firstName = State(initialValue: accountInformationViewModel.firstName)
        self._lastName = State(initialValue: accountInformationViewModel.lastName)
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("First Name:")
                        
                    TextField("", text: $firstName)
                        .padding(0)
                }
                
                if isFirstNameErrorShown {
                    Text("                      Enter a first name")
                        .foregroundStyle(Color(.systemRed))
                        .padding(0)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Last Name:")
                        
                    TextField("", text: $lastName)
                        .padding(0)
                }
                
                if isLastNameErrorShown {
                    Text("                      Enter a last name")
                        .foregroundStyle(Color(.systemRed))
                        .padding(0)
                }
            }
            .padding(.horizontal)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.gray.opacity(0.3))
                .padding(.vertical)
            
            HStack {
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                    lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    isFirstNameErrorShown = firstName.isEmpty
                    isLastNameErrorShown = lastName.isEmpty
                    
                    if !firstName.isEmpty && !lastName.isEmpty {
                        accountInformationViewModel.updateName(firstName: self.firstName, lastName: self.lastName)
                    
                        dismiss()
                    }
                } label: {
                    Text("Save")
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .keyboardShortcut(.return)
            }
            .padding(.horizontal)
        }
        .onChange(of: firstName) {
            if isFirstNameErrorShown {
                if !firstName.isEmpty {
                    isFirstNameErrorShown = false
                }
            }
        }
        .onChange(of: lastName) {
            if isLastNameErrorShown {
                if !lastName.isEmpty {
                    isLastNameErrorShown = false
                }
            }
        }
    }
}

#Preview {
    AccountInformationScreen()
}
