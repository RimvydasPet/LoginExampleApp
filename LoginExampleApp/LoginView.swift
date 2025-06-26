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
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            Button("Login") {
                viewModel.login()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Register") {
                showRegister = true
            }
            .padding(.top, 8)
        }
        .padding()
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            HomeView()
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("Welcome! You are logged in.")
            .font(.largeTitle)
            .padding()
    }
}
