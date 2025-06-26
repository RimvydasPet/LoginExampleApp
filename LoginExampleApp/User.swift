import Foundation
import SwiftData

@Model
final class User {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
