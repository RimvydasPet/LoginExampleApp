import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case requestFailed(Error)
    case invalidData
    case decodingError(Error)
}

protocol APIServiceProtocol {
    func fetchExchangeRate(from: String, to: String, amount: Double) -> AnyPublisher<ExchangeRateResponse, APIError>
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    private let baseURL = "https://my.transfergo.com/api/fx-rates"
    
    private init() {}
    
    func fetchExchangeRate(from: String, to: String, amount: Double) -> AnyPublisher<ExchangeRateResponse, APIError> {
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
            .mapError { APIError.requestFailed($0) }
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.invalidResponse
                }
                return data
            }
            .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                } else {
                    return .decodingError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mock API Service for testing
class MockAPIService: APIServiceProtocol {
    var mockResponse: Result<ExchangeRateResponse, APIError> = .failure(.invalidURL)
    
    func fetchExchangeRate(from: String, to: String, amount: Double) -> AnyPublisher<ExchangeRateResponse, APIError> {
        return mockResponse.publisher
            .eraseToAnyPublisher()
    }
}
