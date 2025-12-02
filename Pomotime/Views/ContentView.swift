//
//  ContentView.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI


struct ContentView: View {
    
    @State private var selection = 2
    @Environment(\.colorScheme) private var colorScheme

    private var currentTint: Color {
        switch selection {
        case 1: return Color(r: 255, g: 4, b: 54)
        case 2: return Color(r: 255, g: 84, b: 71)
        case 3: return colorScheme == .dark ? Color(r: 219, g: 209, b: 209) : .gray
        default: return .accentColor
        }
    }

    var body: some View {
        TabView(selection: $selection) {
            MusicView()
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Music")
                }
                .tag(1)

            TimerView().environmentObject(Timers())
                .tabItem {
                    Image(systemName: "deskclock")
                    Text("Timer")
                }
                .tag(2)

            SettingsView().environmentObject(Timers())
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(currentTint)
        .animation(.easeInOut, value: selection)
    }
}



#Preview {
    ContentView()
}
