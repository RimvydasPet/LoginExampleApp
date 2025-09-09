import Foundation
import UIKit

protocol LoginRoutingLogic {
    func routeToHome()
}

final class LoginRouter: LoginRoutingLogic {
    weak var viewController: UIViewController?
    
    func routeToHome() {
    }
}
