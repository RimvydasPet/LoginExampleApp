//
//  LoginExampleAppUITests.swift
//  LoginExampleAppUITests
//
//  Created by Rimvydas on 2025-06-26.
//

import XCTest

final class LoginExampleAppUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    // MARK: - UI Elements
    
    private var usernameField: XCUIElement { app.textFields["usernameField"] }
    private var passwordField: XCUIElement { app.secureTextFields["passwordField"] }
    private var loginButton: XCUIElement { app.buttons["loginButton"] }
    private var registerButton: XCUIElement { app.buttons["registerButton"] }
    private var errorLabel: XCUIElement { app.staticTexts["errorLabel"] }
    private var welcomeText: XCUIElement { app.staticTexts["welcomeText"] }
    private var logoutButton: XCUIElement { app.buttons["logoutButton"] }
    
    // MARK: - Setup & Teardown
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Launch with a clean state for each test
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    // MARK: - Helper Methods
    
    private func login(username: String, password: String) {
        usernameField.tap()
        usernameField.typeText(username)
        passwordField.tap()
        passwordField.typeText(password)
        loginButton.tap()
    }
    
    // MARK: - Tests
    
    func testLoginScreenElementsExist() {
        // Verify all UI elements are present on the login screen
        XCTAssertTrue(usernameField.exists, "Username field should exist")
        XCTAssertTrue(passwordField.exists, "Password field should exist")
        XCTAssertTrue(loginButton.exists, "Login button should exist")
        XCTAssertTrue(registerButton.exists, "Register button should exist")
    }
    
    func testSuccessfulLogin() {
        // Given
        let testUsername = "testuser"
        let testPassword = "password123"
        
        // When
        login(username: testUsername, password: testPassword)
        
        // Then
        // Wait for the home screen to appear
        let welcomeTextPredicate = NSPredicate(format: "label CONTAINS 'Welcome'")
        let welcomeTextElement = app.staticTexts.element(matching: welcomeTextPredicate)
        XCTAssertTrue(welcomeTextElement.waitForExistence(timeout: 5), "Welcome text should be visible after successful login")
    }
    
    func testFailedLogin_InvalidCredentials() {
        // Given
        let invalidUsername = "nonexistent"
        let invalidPassword = "wrongpassword"
        
        // When
        login(username: invalidUsername, password: invalidPassword)
        
        // Then
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2), "Error message should be displayed")
        XCTAssertEqual(errorLabel.label, "Invalid credentials", "Correct error message should be displayed")
    }
    
    func testEmptyFieldsValidation() {
        // When
        loginButton.tap()
        
        // Then
        XCTAssertTrue(errorLabel.exists, "Error message should be displayed for empty fields")
    }
    
    func testNavigationToRegisterScreen() {
        // When
        registerButton.tap()
        
        // Then
        let registerTitle = app.staticTexts["Register"]
        XCTAssertTrue(registerTitle.waitForExistence(timeout: 1), "Should navigate to register screen")
    }
    
    func testLogout() {
        // Given - First login
        testSuccessfulLogin()
        
        // When
        logoutButton.tap()
        
        // Confirm logout alert
        let alert = app.alerts["Log Out"]
        XCTAssertTrue(alert.waitForExistence(timeout: 1), "Logout confirmation alert should appear")
        
        alert.buttons["Log Out"].tap()
        
        // Then
        XCTAssertTrue(loginButton.waitForExistence(timeout: 2), "Should return to login screen after logout")
    }
    
    func testPerformanceLogin() {
        // This measures the time it takes to perform a successful login
        measure(metrics: [XCTCPUMetric(), XCTMemoryMetric()]) {
            login(username: "testuser", password: "password123")
            
            // Wait for login to complete
            let welcomeTextPredicate = NSPredicate(format: "label CONTAINS 'Welcome'")
            _ = app.staticTexts.element(matching: welcomeTextPredicate).waitForExistence(timeout: 5)
            
            // Logout to reset state
            if logoutButton.waitForExistence(timeout: 1) {
                logoutButton.tap()
                app.alerts.buttons["Log Out"].tap()
            }
        }
    }
}
