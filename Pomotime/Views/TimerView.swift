//
//  TimerView.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI


struct TimerView: View {
    @EnvironmentObject var timers: Timers

    
    var body: some View {
        NavigationStack {
            Text("Brother may i have some oats")
                .navigationTitle("Timer")
                .toolbarBackground(Color(r:255, g:99, b:71), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .padding(50)
            Text("Debug output:")
            Text("Work duration: \(timers.workSession)")
            Text("Short break duration: \(timers.shortBreak)")
            Text("Long break duration: \(timers.longBreak)")
        }
        
    }
}

#Preview {
    TimerView().environmentObject(Timers())}
