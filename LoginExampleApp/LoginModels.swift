import Foundation

// MARK: - Login Models

enum Login {
    // Request sent from ViewController to Interactor
    struct Request {
        let username: String
        let password: String
    }

    // Response sent from Interactor to Presenter
    struct Response {
        let success: Bool
        let errorMessage: String?
    }

    // ViewModel sent from Presenter to ViewController
    struct ViewModel {
        let success: Bool
        let errorMessage: String?
    }
}
