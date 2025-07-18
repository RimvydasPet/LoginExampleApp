import Foundation

protocol LoginBusinessLogic {
    func login(request: Login.Request)
}

import SwiftData

final class LoginInteractor: LoginBusinessLogic {
    var presenter: LoginPresentationLogic?
    var modelContext: ModelContext?

    func login(request: Login.Request) {
        guard let modelContext else {
            presenter?.presentLogin(response: Login.Response(success: false, errorMessage: "Internal error"))
            return
        }
        
        let usernameToFind = request.username
        let predicate = #Predicate<User> { user in
            user.username == usernameToFind
        }
        
        let fetchDescriptor = FetchDescriptor<User>(predicate: predicate)
        let users = (try? modelContext.fetch(fetchDescriptor)) ?? []
        
        if let user = users.first, user.password == request.password {
            presenter?.presentLogin(response: Login.Response(success: true, errorMessage: nil))
        } else {
            presenter?.presentLogin(response: Login.Response(success: false, errorMessage: "Invalid credentials"))
        }
    }
}

