import Foundation

protocol LoginPresentationLogic {
    func presentLogin(response: Login.Response)
}

final class LoginPresenter: LoginPresentationLogic {
    weak var viewController: LoginDisplayLogic?
    
    func presentLogin(response: Login.Response) {
        let viewModel = Login.ViewModel(success: response.success, errorMessage: response.errorMessage)
        viewController?.displayLogin(viewModel: viewModel)
    }
}
