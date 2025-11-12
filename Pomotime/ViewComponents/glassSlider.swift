//
//  OptionSlider.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 11. 11. 25.
//

import SwiftUI

struct glassSlider: View {
        @Binding var value: Int
        let title: String
        let range: ClosedRange<Double>
        let step: Double
        let tint: Color
        let backgorund: Color
        
        var body: some View {
            VStack {
                HStack {
                    Text(title)
                    Spacer()
                    Text("\(value) min")
                }

                Slider(
                    value: Binding(
                        get: { Double(value) },
                        set: {
                            let rounded = Int($0.rounded())
                            value = max(1, rounded)
                        }
                    ),
                    in: range,
                    step: step,
                    onEditingChanged: { editing in
                        withAnimation(.easeInOut(duration: 0.2)) {
                        }
                    }
                ) {
                    Text(title)
                }
                .padding(10)
                .tint(tint)
            }
            .padding(16)
            .glassEffect(
                .regular.tint(backgorund).interactive(),
                in: .rect(cornerRadius: 28.0)
            )
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
