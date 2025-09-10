import SwiftUI
import SwiftData
//import CurrencyConverter

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = LoginViewModel()
    @State private var showRegister = false
    
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        ZStack {
            gradient
                .opacity(0.2)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Sign in to access your account")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Enter your username", text: $viewModel.username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .accessibilityIdentifier("usernameField")
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("Enter your password", text: $viewModel.password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityIdentifier("passwordField")
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .accessibilityIdentifier("errorLabel")
                    }
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding(.top, 10)
                    .accessibilityIdentifier("loginButton")
                    
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.vertical)
                    
                    Button(action: {
                        showRegister = true
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .accessibilityIdentifier("registerButton")
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                
                Spacer()
                
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.modelContext = modelContext
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn, onDismiss: {
            viewModel.isLoggedIn = false
            viewModel.username = ""
            viewModel.password = ""
            viewModel.errorMessage = nil
        }) {
            NavigationView {
                CurrencyConverterView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Logout") {
                                viewModel.isLoggedIn = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}
