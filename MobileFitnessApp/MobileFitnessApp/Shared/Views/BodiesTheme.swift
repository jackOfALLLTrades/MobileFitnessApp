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
    case eggshell = "Eggshell"
    case xcode = "Xcode"

    var colorScheme: ColorScheme {
        switch self {
        case .light, .eggshell: .light
        case .dark, .xcode: .dark
        }
    }

    var accent: Color {
        switch self {
        case .light, .dark: .blue
        case .eggshell: Color(red: 0.37, green: 0.27, blue: 0.17)
        case .xcode: Color(red: 0.76, green: 0.62, blue: 0.98)
        }
    }

    var background: Color {
        switch self {
        case .light: Color(red: 0.95, green: 0.95, blue: 0.97)
        case .dark: .black
        case .eggshell: Color(red: 0.95, green: 0.92, blue: 0.86)
        case .xcode: Color(red: 0.12, green: 0.13, blue: 0.16)
        }
    }

    var surface: Color {
        switch self {
        case .light: .white
        case .dark: Color(red: 0.11, green: 0.11, blue: 0.12)
        case .eggshell: Color(red: 0.99, green: 0.97, blue: 0.93)
        case .xcode: Color(red: 0.17, green: 0.18, blue: 0.22)
        }
    }

    var usesCustomSurfaces: Bool { self == .eggshell || self == .xcode }
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
