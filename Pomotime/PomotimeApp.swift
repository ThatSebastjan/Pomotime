//
//  PomotimeApp.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI

extension Color {
    init(r: Int, g: Int, b: Int, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: opacity)
    }
}

@main
struct PomotimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Timers())
        }
    }
}
