import SwiftUI

import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .padding(.top, 32)
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
                .accessibilityIdentifier("usernameField")
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .accessibilityIdentifier("passwordField")
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("errorLabel")
            }
            Button("Login") {
                viewModel.login()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .accessibilityIdentifier("loginButton")

            Button("Register") {
                showRegister = true
            }
            .padding(.top, 8)
            .accessibilityIdentifier("registerButton")
        }
        .padding()
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn, onDismiss: {
            // Reset the login state when HomeView is dismissed (after logout)
            viewModel.isLoggedIn = false
            viewModel.username = ""
            viewModel.password = ""
            viewModel.errorMessage = nil
        }) {
            HomeView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingLogoutAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .accessibilityIdentifier("welcomeText")
            
            Text("You are successfully logged in.")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                showingLogoutAlert = true
            }) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .accessibilityIdentifier("logoutButton")
            }
            .padding(.horizontal)
        }
        .padding()
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                // Dismiss the home view and return to login
                dismiss()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
}
