import UIKit

protocol LoginDisplayLogic: AnyObject {
    func displayLogin(viewModel: Login.ViewModel)
}

final class LoginViewController: UIViewController, LoginDisplayLogic {
    var interactor: LoginBusinessLogic?
    var router: LoginRoutingLogic?
    
    private let usernameField = UITextField()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupUI()
    }
    
    private func setup() {
        let viewController = self
        let interactor = LoginInteractor()
        let presenter = LoginPresenter()
        let router = LoginRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        usernameField.placeholder = "Username"
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
        loginButton.setTitle("Login", for: .normal)
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        usernameField.borderStyle = .roundedRect
        passwordField.borderStyle = .roundedRect
        
        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, loginButton, errorLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }
    
    @objc private func loginTapped() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        let request = Login.Request(username: username, password: password)
        interactor?.login(request: request)
    }
    
    func displayLogin(viewModel: Login.ViewModel) {
        if viewModel.success {
            errorLabel.text = nil
            // Route to home
            router?.routeToHome()
        } else {
            errorLabel.text = viewModel.errorMessage
        }
    }
}
