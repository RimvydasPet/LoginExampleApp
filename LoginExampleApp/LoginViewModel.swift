import Foundation
import Combine

import SwiftData

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoggedIn: Bool = false

    private var interactor: LoginBusinessLogic

    var modelContext: ModelContext? {
        didSet {
            if let interactor = interactor as? LoginInteractor {
                interactor.modelContext = modelContext
            }
        }
    }

    init() {
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.onPresentLogin = { [weak self] response in
            DispatchQueue.main.async {
                self?.isLoggedIn = response.success
                self?.errorMessage = response.errorMessage
            }
        }
    }

    func login() {
        let request = Login.Request(username: username, password: password)
        interactor.login(request: request)
    }
}
