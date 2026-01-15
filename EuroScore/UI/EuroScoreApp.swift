//
//  EuroScoreApp.swift
//  EuroScore
//
//  Created by Edward Bender on 1/13/26.
//

import SwiftUI

@main
struct EuroScoreApp: App {
    @StateObject private var euroscoreVM = EuroscoreViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(euroscoreVM)
        }
    }
}
