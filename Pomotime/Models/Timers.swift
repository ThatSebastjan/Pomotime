//
//  Timers.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 10. 11. 25.
//

import Foundation
import Combine
import SwiftUI

final class Timers: ObservableObject {
    @Published var shortBreak: Int { didSet { save() } }
    @Published var longBreak: Int { didSet { save() } }
    @Published var workSession: Int { didSet { save() } }

    private enum Keys {
        static let shortBreak = "Timers.shortBreak"
        static let longBreak = "Timers.longBreak"
        static let workSession = "Timers.workSession"
    }

    private func save() {
        let defaults = UserDefaults.standard
        defaults.set(shortBreak, forKey: Keys.shortBreak)
        defaults.set(longBreak, forKey: Keys.longBreak)
        defaults.set(workSession, forKey: Keys.workSession)
    }

    init() {
        // Load saved values if available, otherwise use defaults
        let defaults = UserDefaults.standard
        let short = defaults.integer(forKey: Keys.shortBreak)
        let long = defaults.integer(forKey: Keys.longBreak)
        let work = defaults.integer(forKey: Keys.workSession)

        // If no value was saved before, fall back to defaults (5, 30, 25)
        self.shortBreak = short == 0 ? 5 : short
        self.longBreak = long == 0 ? 30 : long
        self.workSession = work == 0 ? 25 : work
    }

    func setTimers(shortBreak: Int, longBreak: Int, workSession: Int) {
        DispatchQueue.main.async {
            self.shortBreak = shortBreak
            self.longBreak = longBreak
            self.workSession = workSession
        }
    }

    func getTimers() -> (shortBreak: Int, longBreak: Int, workSession: Int) {
        return (shortBreak: shortBreak, longBreak: longBreak, workSession: workSession)
    }
}

