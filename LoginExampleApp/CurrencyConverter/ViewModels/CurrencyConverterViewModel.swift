import Foundation
import Combine

class CurrencyConverterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var fromCurrency: Currency
    @Published var toCurrency: Currency
    @Published var fromAmount: String = "300.00"
    @Published var toAmount: String = ""
    @Published var exchangeRate: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        self.fromCurrency = Currency.defaultFromCurrency
        self.toCurrency = Currency.defaultToCurrency
        
        // Setup amount change publisher with debounce
        $fromAmount
            .dropFirst() // Skip initial value
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // Wait for typing to stop
            .removeDuplicates() // Only proceed if value changed
            .sink { [weak self] _ in
                self?.convert()
            }
            .store(in: &cancellables)
        
        // Initial conversion
        convert()
        
        // Observe currency changes to trigger conversion
        $fromCurrency
            .dropFirst()
            .sink { [weak self] _ in
                self?.convert()
            }
            .store(in: &cancellables)
        
        $toCurrency
            .dropFirst()
            .sink { [weak self] _ in
                self?.convert()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func convert() {
        guard let amount = Float(fromAmount) else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        // Validate amount doesn't exceed max limit
        if amount > fromCurrency.maxAmount {
            errorMessage = "Amount exceeds maximum limit of \(fromCurrency.maxAmount) \(fromCurrency.code)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        apiService.fetchExchangeRate(
            from: fromCurrency.code,
            to: toCurrency.code,
            amount: amount
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            },
            receiveValue: { [weak self] response in
                self?.updateWithResponse(response)
            }
        )
        .store(in: &cancellables)
    }
    
    func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
        
        // Keep the same numeric value but swap the amounts
        let tempAmount = fromAmount
        fromAmount = toAmount
        toAmount = tempAmount
    }
    
    // MARK: - Private Methods
    private func updateWithResponse(_ response: ExchangeRateResponse) {
        exchangeRate = response.rate
        toAmount = numberFormatter.string(from: NSNumber(value: response.toAmount)) ?? ""
    }
    
    private func handleError(_ error: APIError) {
        switch error {
        case .invalidURL:
            errorMessage = "Invalid URL"
        case .invalidResponse:
            errorMessage = "Invalid response from server"
        case .requestFailed(let error):
            errorMessage = "No network  \nCheck your internet connection"
        case .invalidData:
            errorMessage = "Invalid data received"
        case .decodingError:
            errorMessage = "Failed to decode response"
        }
    }
}
