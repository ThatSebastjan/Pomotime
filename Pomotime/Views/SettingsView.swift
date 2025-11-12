//
//  SettingsView.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var timers: Timers

    @State private var isEditingWork = false
    @State private var isEditingShort = false
    @State private var isEditingLong = false

    private var titleBarColor: Color {
        if colorScheme == .light {
            return Color(
                red: 176.0/255.0,
                green: 167.0/255.0,
                blue: 167.0/255.0
            )
        } else {
            return Color(
                red: 196.0/255.0,
                green: 187.0/255.0,
                blue: 187.0/255.0
            )
        }
    }

    private var textColor: Color {
        if colorScheme == .light {
            return Color.black
        } else {
            return Color.white
        }
    }


    var body: some View {
        NavigationStack {
            GlassEffectContainer() {
                Spacer(minLength: 25)
                    .navigationTitle("Settings")
//                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbarBackground(titleBarColor, for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        glassSlider(
                            value: $timers.workSession,
                            title: "Work Session",
                            range: 15...60,
                            step: 5,
                            tint: .green,
                            backgorund: .clear
                        )
                        
                        
                        
                        glassSlider(
                            value: $timers.shortBreak,
                            title: "Short Break",
                            range: 0...15,
                            step: 5,
                            tint: .red,
                            backgorund: .clear
                        )
                        
                        
                        glassSlider(
                            value: $timers.longBreak,
                            title: "Long Break",
                            range: 20...45,
                            step: 5,
                            tint: .orange,
                            backgorund: .clear
                        )
                        
                        
                        Button(role: .destructive) {
                            withAnimation {
                                timers.setTimers(
                                    shortBreak: 5,
                                    longBreak: 30,
                                    workSession: 25
                                )
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Defaults")
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        .padding(12)
                        .tint(.red)
                        .frame(maxWidth: .infinity ,alignment: .center)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .frame(minWidth: 0, maxWidth:650, alignment: .leading)
            
        }
    }
}


#Preview {
    SettingsView().environmentObject(Timers())
}

