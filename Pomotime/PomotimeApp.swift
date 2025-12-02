//
//  PomotimeApp.swift
//  Pomotime
//
//  Created by Sebastjan Gomboc on 6. 10. 25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Color {
    init(r: Int, g: Int, b: Int, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: opacity)
    }
}

#if canImport(UIKit)
private struct MinimumWindowSizeModifier: ViewModifier {
    let minWidth: CGFloat
    let minHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .background(WindowSizeRestrictionApplicator(minWidth: minWidth, minHeight: minHeight))
    }
}

private struct WindowSizeRestrictionApplicator: UIViewRepresentable {
    let minWidth: CGFloat
    let minHeight: CGFloat

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        DispatchQueue.main.async {
            if let windowScene = view.window?.windowScene,
               let restrictions = windowScene.sizeRestrictions {
                restrictions.minimumSize = CGSize(width: minWidth, height: minHeight)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let windowScene = uiView.window?.windowScene,
               let restrictions = windowScene.sizeRestrictions {
                restrictions.minimumSize = CGSize(width: minWidth, height: minHeight)
            }
        }
    }
}

private extension View {
    func minimumWindowSize(width: CGFloat, height: CGFloat) -> some View {
        modifier(MinimumWindowSizeModifier(minWidth: width, minHeight: height))
    }
}
#endif // canImport(UIKit)

@main
struct PomotimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Timers())
#if canImport(UIKit)
                .minimumWindowSize(width: 650, height: 800)
#endif
        }
    }
}
