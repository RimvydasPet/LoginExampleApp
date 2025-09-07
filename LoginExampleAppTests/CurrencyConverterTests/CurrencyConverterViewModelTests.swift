import XCTest
import Combine
@testable import LoginExampleApp

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
        XCTAssertEqual(viewModel.fromCurrency.code, "PLN")
        XCTAssertEqual(viewModel.toCurrency.code, "UAH")
        XCTAssertEqual(viewModel.fromAmount, "300.00")
        XCTAssertTrue(viewModel.toAmount.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
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
    }
}
