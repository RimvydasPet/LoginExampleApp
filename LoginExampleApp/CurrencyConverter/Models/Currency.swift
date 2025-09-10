import Foundation

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let flagName: String
    let maxAmount: Float
    
    // Predefined list of supported currencies with their max limits
    static let supportedCurrencies: [Currency] = [
        Currency(code: "PLN", name: "Polish Złoty", flagName: "Icon PL", maxAmount: 20000),
        Currency(code: "EUR", name: "Euro", flagName: "Icon DE", maxAmount: 5000),
        Currency(code: "GBP", name: "British Pound", flagName: "Icon UK", maxAmount: 1000),
        Currency(code: "UAH", name: "Ukrainian Hryvnia", flagName: "Icon UA", maxAmount: 50000)
    ]
    
    static var defaultFromCurrency: Currency {
        supportedCurrencies.first(where: { $0.code == "PLN" })!
    }
    
    static var defaultToCurrency: Currency {
        supportedCurrencies.first(where: { $0.code == "UAH" })!
    }
}

// MARK: - Exchange Rate Response
struct ExchangeRateResponse: Decodable {
    let from: String
    let to: String
    let fromAmount: Float
    let toAmount: Float
    let rate: Double
    
    enum CodingKeys: String, CodingKey {
        case from, to, rate
        case fromAmount = "fromAmount"
        case toAmount = "toAmount"
    }
}
