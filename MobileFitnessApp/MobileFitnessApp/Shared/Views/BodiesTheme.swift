//
//  BodiesTheme.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/9/26.
//

import SwiftUI

enum BodiesTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case springCream = "Spring Cream"
    case xcode = "Xcode"

    var displayName: String { self == .springCream ? "Spring" : rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .light, .springCream: .light
        case .dark, .xcode: .dark
        }
    }

    var accent: Color {
        switch self {
        case .light: .blue
        case .dark: Color(red: 1.00, green: 0.63, blue: 0.30)
        case .springCream: Color(red: 67.0 / 255, green: 176.0 / 255, blue: 42.0 / 255)
        case .xcode: Color(red: 0.76, green: 0.62, blue: 0.98)
        }
    }

    var background: Color {
        switch self {
        case .light: Color(red: 0.95, green: 0.95, blue: 0.97)
        case .dark: Color(red: 0.07, green: 0.07, blue: 0.08)
        case .springCream: Color(red: 233.0 / 255, green: 233.0 / 255, blue: 230.0 / 255)
        case .xcode: Color(red: 0.12, green: 0.13, blue: 0.16)
        }
    }

    var surface: Color {
        switch self {
        case .light: .white
        case .dark: Color(red: 0.13, green: 0.13, blue: 0.14)
        case .springCream: Color(red: 0.98, green: 0.97, blue: 0.95)
        case .xcode: Color(red: 0.17, green: 0.18, blue: 0.22)
        }
    }

    var usesCustomSurfaces: Bool { self != .light }
}

private struct ThemeBackground: ViewModifier {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(theme.usesCustomSurfaces ? .hidden : .automatic)
            // Rebuild the list or form so its existing rows cannot retain the old palette.
            .id(theme)
            .background {
                if theme.usesCustomSurfaces {
                    theme.background.ignoresSafeArea()
                }
            }
    }
}

private struct ThemeListRow: ViewModifier {
    @AppStorage(AppPreferences.themeKey) private var theme: BodiesTheme = .light

    func body(content: Content) -> some View {
        content.listRowBackground(theme.usesCustomSurfaces ? theme.surface : nil)
    }
}

extension View {
    func themeBackground() -> some View {
        modifier(ThemeBackground())
    }

    func themeListRow() -> some View {
        modifier(ThemeListRow())
    }
}
