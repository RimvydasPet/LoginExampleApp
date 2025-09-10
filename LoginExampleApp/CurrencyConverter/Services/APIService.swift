import Foundation
import Combine

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case requestFailed(NSError)
    case networkError(description: String)
    case invalidData
    case decodingError(NSError)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.requestFailed(let lhsError), .requestFailed(let rhsError)):
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        case (.networkError(let lhsDesc), .networkError(let rhsDesc)):
            return lhsDesc == rhsDesc
        case (.invalidData, .invalidData):
            return true
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        default:
            return false
        }
    }
}

protocol APIServiceProtocol {
    func fetchExchangeRate(from: String, to: String, amount: Float) -> AnyPublisher<ExchangeRateResponse, APIError>
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    private let baseURL = "https://my.transfergo.com/api/fx-rates"
    
    private init() {}
    
    func fetchExchangeRate(from: String, to: String, amount: Float) -> AnyPublisher<ExchangeRateResponse, APIError> {
        guard var components = URLComponents(string: baseURL) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "amount", value: String(amount))
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { error -> APIError in
                let nsError = error as NSError
                return .requestFailed(nsError)
            }
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP Error: \(response)")
                    throw APIError.invalidResponse
                }
                return data
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .requestFailed(error as NSError)
                }
            }
            .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                print("Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    let nsError = NSError(domain: "DecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: String(describing: decodingError)])
                    return .decodingError(nsError)
                } else {
                    return .decodingError(error as NSError)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock API Service for testing
class MockAPIService: APIServiceProtocol {
    var mockResponse: Result<ExchangeRateResponse, APIError> = .failure(.invalidURL)
    
    func fetchExchangeRate(from: String, to: String, amount: Float) -> AnyPublisher<ExchangeRateResponse, APIError> {
        return mockResponse.publisher
            .eraseToAnyPublisher()
    }
}
