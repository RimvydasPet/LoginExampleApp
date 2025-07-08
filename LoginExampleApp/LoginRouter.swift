import Foundation
import UIKit

protocol LoginRoutingLogic {
    func routeToHome()
}

final class LoginRouter: LoginRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToHome() {
        // Example:
        // let homeVC = HomeViewController()
        // viewController?.navigationController?.pushViewController(homeVC, animated: true)
    }
}
