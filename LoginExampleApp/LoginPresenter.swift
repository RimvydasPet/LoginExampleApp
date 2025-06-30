import Foundation

protocol LoginPresentationLogic {
    func presentLogin(response: Login.Response)
}

final class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    var onPresentLogin: ((Login.Response) -> Void)?

    func presentLogin(response: Login.Response) {
        let viewModel = Login.ViewModel(success: response.success, errorMessage: response.errorMessage)
        viewController?.displayLogin(viewModel: viewModel)
        // Notify SwiftUI if closure is set
        onPresentLogin?(response)
    }
}
