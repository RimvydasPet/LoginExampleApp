//
//  LoginExampleApp.swift
//  LoginExampleApp
//
//  Created by Rimvydas on 2025-06-26.
//

import SwiftUI
import SwiftData

@main
struct LoginExampleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(sharedModelContainer)
    }
}
