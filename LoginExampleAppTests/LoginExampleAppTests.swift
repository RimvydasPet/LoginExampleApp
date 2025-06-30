//
//  LoginExampleAppTests.swift
//  LoginExampleAppTests
//
//  Created by Rimvydas on 2025-06-26.
//

import XCTest
import SwiftData
@testable import LoginExampleApp

// MARK: - Mock Classes

class MockLoginPresenter: LoginPresentationLogic {
    var presentLoginCalled = false
    var receivedResponse: Login.Response?
    
    func presentLogin(response: Login.Response) {
        presentLoginCalled = true
        receivedResponse = response
    }
}

// MARK: - Test Classes

final class LoginExampleAppTests: XCTestCase {
    
    // MARK: - Properties
    
    var viewModel: LoginViewModel!
    var interactor: LoginInteractor!
    var mockPresenter: MockLoginPresenter!
    var modelContext: ModelContext!
    var container: ModelContainer!
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        try super.setUp()
        
        // Set up in-memory storage for testing
        let schema = Schema([
            User.self,
        ])
        
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(container)
        
        // Set up test objects
        mockPresenter = MockLoginPresenter()
        interactor = LoginInteractor()
        interactor.presenter = mockPresenter
        interactor.modelContext = modelContext
        
        viewModel = LoginViewModel()
        viewModel.modelContext = modelContext
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        interactor = nil
        mockPresenter = nil
        modelContext = nil
        container = nil
        try super.tearDown()
    }

    // MARK: - Helper Methods
    
    private func createTestUser(username: String, password: String) -> User {
        let user = User(username: username, password: password)
        modelContext.insert(user)
        try? modelContext.save()
        return user
    }
    
    // MARK: - LoginViewModel Tests
    
    func testLoginViewModel_InitialState() {
        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoggedIn)
    }
    
    func testLoginViewModel_LoginSuccess() {
        // Given
        let testUser = createTestUser(username: "testuser", password: "password123")
        viewModel.username = testUser.username
        viewModel.password = testUser.password
        
        // When
        let expectation = XCTestExpectation(description: "Login completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        viewModel.login()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLoggedIn)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoginViewModel_LoginFailure() {
        // Given
        viewModel.username = "nonexistent"
        viewModel.password = "wrongpassword"
        
        // When
        let expectation = XCTestExpectation(description: "Login completion")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        viewModel.login()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoggedIn)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Invalid credentials")
    }
    
    // MARK: - LoginInteractor Tests
    
    func testLoginInteractor_LoginSuccess() {
        // Given
        let testUser = createTestUser(username: "testuser", password: "password123")
        let request = Login.Request(username: testUser.username, password: testUser.password)
        
        // When
        interactor.login(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoginCalled)
        XCTAssertNotNil(mockPresenter.receivedResponse)
        XCTAssertTrue(mockPresenter.receivedResponse?.success == true)
        XCTAssertNil(mockPresenter.receivedResponse?.errorMessage)
    }
    
    func testLoginInteractor_LoginFailure_WrongPassword() {
        // Given
        let testUser = createTestUser(username: "testuser", password: "password123")
        let request = Login.Request(username: testUser.username, password: "wrongpassword")
        
        // When
        interactor.login(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoginCalled)
        XCTAssertNotNil(mockPresenter.receivedResponse)
        XCTAssertFalse(mockPresenter.receivedResponse?.success ?? true)
        XCTAssertEqual(mockPresenter.receivedResponse?.errorMessage, "Invalid credentials")
    }
    
    func testLoginInteractor_LoginFailure_UserNotFound() {
        // Given
        let request = Login.Request(username: "nonexistent", password: "password123")
        
        // When
        interactor.login(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoginCalled)
        XCTAssertNotNil(mockPresenter.receivedResponse)
        XCTAssertFalse(mockPresenter.receivedResponse?.success ?? true)
        XCTAssertEqual(mockPresenter.receivedResponse?.errorMessage, "Invalid credentials")
    }
    
    func testLoginInteractor_NilModelContext() {
        // Given
        interactor.modelContext = nil
        let request = Login.Request(username: "test", password: "password")
        
        // When
        interactor.login(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoginCalled)
        XCTAssertNotNil(mockPresenter.receivedResponse)
        XCTAssertFalse(mockPresenter.receivedResponse?.success ?? true)
        XCTAssertEqual(mockPresenter.receivedResponse?.errorMessage, "Internal error")
    }
    
    // MARK: - Performance Tests
    
    func testLoginPerformance() {
        // Create multiple test users
        for i in 0..<100 {
            _ = createTestUser(username: "user\(i)", password: "password\(i)")
        }
        
        // Measure login time
        measure {
            let request = Login.Request(username: "user99", password: "password99")
            interactor.login(request: request)
        }
    }

}
