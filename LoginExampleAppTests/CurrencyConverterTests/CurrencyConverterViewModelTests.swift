import XCTest
import Combine
@testable import LoginExampleApp

// MARK: - MockAPIService
class MockAPIService: APIServiceProtocol {
    var mockResponse: Result<ExchangeRateResponse, APIError> = .failure(.invalidResponse)
    
    func fetchExchangeRate(from: String, to: String, amount: Float) -> AnyPublisher<ExchangeRateResponse, APIError> {
        return Future<ExchangeRateResponse, APIError> { promise in
            switch self.mockResponse {
            case .success(let response):
                promise(.success(response))
            case .failure(let error):
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}

class CurrencyConverterViewModelTests: XCTestCase {
    var viewModel: CurrencyConverterViewModel!
    var mockAPIService: MockAPIService!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = CurrencyConverterViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testInitialState() {
        // Given
        let expectation = self.expectation(description: "Initial state setup")
        
        // When - Wait for the initial conversion to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Then - Verify initial state
            // Test 1: Check from currency code
            XCTAssertEqual(self.viewModel.fromCurrency.code, "PLN")
            
            // Test 2: Check to currency code
            XCTAssertEqual(self.viewModel.toCurrency.code, "UAH")
            
            // Test 3: Check loading state should be false after initial load
            XCTAssertFalse(self.viewModel.isLoading)
            
            // Test 4: Check error message should be nil initially
            XCTAssertNil(self.viewModel.errorMessage)
            
            // Test 5: Check exchange rate should be 0.0 initially
            XCTAssertEqual(self.viewModel.exchangeRate, 0.0)
            
            // Test 6: Check toAmount is empty initially
            XCTAssertTrue(self.viewModel.toAmount.isEmpty)
            
            // Test 7: Check fromAmount is not empty and has a valid format
            XCTAssertFalse(self.viewModel.fromAmount.isEmpty)
            
            // Test 8: Check fromAmount can be converted to a number
            let amountString = self.viewModel.fromAmount.replacingOccurrences(of: ",", with: ".")
            let amount = Float(amountString)
            XCTAssertNotNil(amount, "From amount should be a valid number")
            
            expectation.fulfill()
        }
        
        // Wait for expectations with a reasonable timeout
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testConvertSuccess() {
        // Given
        let expectedResponse = ExchangeRateResponse(
            from: "PLN",
            to: "UAH",
            fromAmount: 100,
            toAmount: 750.50,
            rate: 7.505
        )
        mockAPIService.mockResponse = .success(expectedResponse)
        
        let expectation = self.expectation(description: "Conversion completed")
        
        // When
        viewModel.convert()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.toAmount, "750.50")
            XCTAssertEqual(self.viewModel.exchangeRate, 7.505)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testConvertFailure() {
        // Given
        mockAPIService.mockResponse = .failure(.invalidResponse)
        
        let expectation = self.expectation(description: "Conversion failed")
        
        // When
        viewModel.convert()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.toAmount.isEmpty)
            XCTAssertNotNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAmountValidation() {
        // Given
        viewModel.fromCurrency = Currency.supportedCurrencies.first(where: { $0.code == "PLN" })! // Max 20000 PLN
        
        // Test valid amount
        viewModel.fromAmount = "10000.50"
        viewModel.convert()
        XCTAssertNil(viewModel.errorMessage)
        
        // Test amount exceeding limit
        viewModel.fromAmount = "25000.00"
        viewModel.convert()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("exceeds maximum limit") ?? false)
    }
    
    func testSwapCurrencies() {
        // Given
        let initialFrom = viewModel.fromCurrency
        let initialTo = viewModel.toCurrency
        
        // When
        viewModel.swapCurrencies()
        
        // Then
        XCTAssertEqual(viewModel.fromCurrency, initialTo)
        XCTAssertEqual(viewModel.toCurrency, initialFrom)
        
        // When swap back
        viewModel.swapCurrencies()
        
        // Then should return to initial state
        XCTAssertEqual(viewModel.fromCurrency, initialFrom)
        XCTAssertEqual(viewModel.toCurrency, initialTo)
    }
    
    func testConvertWithSameCurrencies() {
        // Given
        viewModel.toCurrency = viewModel.fromCurrency
        let expectation = self.expectation(description: "Same currency conversion")
        
        // When
        viewModel.convert()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.toAmount, self.viewModel.fromAmount)
            XCTAssertEqual(self.viewModel.exchangeRate, 1.0)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testConvertWithInvalidAmount() {
        // Given
        viewModel.fromAmount = "invalid"
        
        // When
        viewModel.convert()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid amount")
    }
    
    func testConvertWithZeroAmount() {
        // Given
        viewModel.fromAmount = "0"
        
        // When
        viewModel.convert()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Amount must be greater than zero")
    }
    
    func testConvertWithNegativeAmount() {
        // Given
        viewModel.fromAmount = "-100"
        
        // When
        viewModel.convert()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Amount must be greater than zero")
    }
    
    func testConvertWithNetworkError() {
        // Given
        mockAPIService.mockResponse = .failure(.networkError(description: "No internet connection"))
        let expectation = self.expectation(description: "Network error")
        
        // When
        viewModel.convert()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.toAmount.isEmpty)
            XCTAssertEqual(self.viewModel.errorMessage, "No internet connection")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testConvertWithInvalidResponse() {
        // Given
        mockAPIService.mockResponse = .failure(.invalidResponse)
        let expectation = self.expectation(description: "Invalid response")
        
        // When
        viewModel.convert()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.toAmount.isEmpty)
            XCTAssertEqual(self.viewModel.errorMessage, "Invalid response from server")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAmountFormatting() {
        // Test valid number formatting
        viewModel.fromAmount = "1000.50"
        XCTAssertEqual(viewModel.fromAmount, "1,000.50")
        
        // Test invalid input
        viewModel.fromAmount = "1,000.50.00"
        XCTAssertEqual(viewModel.fromAmount, "1,000.50")
        
        // Test empty input
        viewModel.fromAmount = ""
        XCTAssertTrue(viewModel.fromAmount.isEmpty)
    }
        
}
