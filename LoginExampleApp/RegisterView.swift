import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var registrationSuccess = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            Button("Register") {
                register()
            }
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .alert("Registration Successful", isPresented: $registrationSuccess) {
            Button("OK") { dismiss() }
        }
    }

    private func register() {
        errorMessage = nil
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        // Check if user exists
        let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        let existingUsers = (try? modelContext.fetch(fetchDescriptor)) ?? []
        guard existingUsers.isEmpty else {
            errorMessage = "User already exists."
            return
        }
        let user = User(username: username, password: password)
        modelContext.insert(user)
        try? modelContext.save()
        registrationSuccess = true
    }
}
