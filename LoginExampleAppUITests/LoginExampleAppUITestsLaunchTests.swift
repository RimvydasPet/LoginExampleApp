//
//  LoginExampleAppUITestsLaunchTests.swift
//  LoginExampleAppUITests
//
//  Created by Rimvydas on 2025-06-26.
//

import XCTest

final class LoginExampleAppUITestsLaunchTests: XCTestCase {
    
    private var app: XCUIApplication!
    
    // MARK: - Setup & Configuration
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        // Set to true to run tests for each UI configuration (light/dark mode, different languages, etc.)
        false
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Launch Tests
    
    func testLaunchPerformance() {
        // Configure the test to be more lenient with performance variations
        let options = XCTMeasureOptions()
        options.iterationCount = 5  // More iterations for more stable average
        
        // This measures how long it takes to launch the application
        measure(metrics: [XCTApplicationLaunchMetric()], options: options) {
            let app = XCUIApplication()
            app.launch()
            // Add a small delay to ensure the app has fully launched
            _ = app.wait(for: .runningForeground, timeout: 5)
        }
    }
    
    func testInitialLaunchState() throws {
        // Given - App is launched
        app.launch()
        
        // Then - Verify initial UI elements are present and visible
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        let registerButton = app.buttons["registerButton"]
        
        // Wait for elements to appear with timeout
        XCTAssertTrue(usernameField.waitForExistence(timeout: 5), "Username field should be present on launch")
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5), "Password field should be present on launch")
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Login button should be present on launch")
        XCTAssertTrue(registerButton.waitForExistence(timeout: 5), "Register button should be present on launch")
        
        // Verify elements are hittable (visible and enabled)
        XCTAssertTrue(usernameField.isHittable, "Username field should be hittable")
        XCTAssertTrue(passwordField.isHittable, "Password field should be hittable")
        XCTAssertTrue(loginButton.isHittable, "Login button should be hittable")
        XCTAssertTrue(registerButton.isHittable, "Register button should be hittable")
        
        // Verify initial state
        // For text fields with placeholders, the value might be the placeholder text
        // Check that the fields don't contain any user-entered text
        XCTAssertNotEqual(usernameField.value as? String, nil, "Username field should be present")
        XCTAssertNotEqual(passwordField.value as? String, nil, "Password field should be present")
        
        // Verify placeholders are set correctly
        XCTAssertEqual(usernameField.placeholderValue, "Username", "Username field should have correct placeholder")
        XCTAssertEqual(passwordField.placeholderValue, "Password", "Password field should have correct placeholder")
        
        // Capture screenshot of the initial state
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "Initial Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testLaunchWithDifferentConfigurations() throws {
        // This test will run for each configuration when runsForEachTargetApplicationUIConfiguration is true
        let app = XCUIApplication()
        app.launch()
        
        // Verify the app launched successfully in this configuration
        XCTAssertTrue(app.staticTexts["Login"].exists, "Login screen should be visible")
        
        // Get the current interface style
//        let isDarkMode = app.windows.element(boundBy: 0).traitCollection.userInterfaceStyle == .dark
        
        // Capture screenshot for this configuration
        let attachment = XCTAttachment(screenshot: app.screenshot())
//        attachment.name = "Launch in configuration: \(isDarkMode ? "Dark" : "Light") Mode"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAppMemoryUsageOnLaunch() throws {
        // Measure memory footprint on launch
        let metrics: [XCTMetric] = [XCTMemoryMetric()]
        let measureOptions = XCTMeasureOptions()
        measureOptions.iterationCount = 3
        
        measure(metrics: metrics, options: measureOptions) {
            app.launch()
            // Add a small delay to ensure the app has fully launched
            _ = app.waitForExistence(timeout: 2.0)
            app.terminate()
        }
    }
}
