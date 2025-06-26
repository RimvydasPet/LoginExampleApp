import Foundation

protocol LoginBusinessLogic {
    func login(request: Login.Request)
}

final class LoginInteractor: LoginBusinessLogic {
    var presenter: LoginPresentationLogic?
    
    func login(request: Login.Request) {
        // Simulate login logic
        if request.username == "admin" && request.password == "password" {
            let response = Login.Response(success: true, errorMessage: nil)
            presenter?.presentLogin(response: response)
        } else {
            let response = Login.Response(success: false, errorMessage: "Invalid credentials")
            presenter?.presentLogin(response: response)
        }
    }
}
