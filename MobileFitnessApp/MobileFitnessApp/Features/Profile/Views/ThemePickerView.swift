//
//  ThemePickerView.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/9/26.
//

import SwiftUI

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var theme: BodiesTheme
    @State private var selection: BodiesTheme

    init(theme: Binding<BodiesTheme>) {
        _theme = theme
        _selection = State(initialValue: theme.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                    ForEach(BodiesTheme.allCases, id: \.self) { option in
                        Button {
                            selection = option
                        } label: {
                            preview(option)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.displayName)
                        .accessibilityAddTraits(selection == option ? .isSelected : [])
                    }
                }
                .padding()
            }
            .themeBackground()
            .navigationTitle("Choose a Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        theme = selection
                        dismiss()
                    }
                }
            }
        }
    }

    private func preview(_ option: BodiesTheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(option.displayName).font(.headline)
                Spacer(minLength: 4)
                Image(systemName: selection == option ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(option.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Workout").font(.subheadline.weight(.semibold))
                Label("Start Routine", systemImage: "play.fill")
                    .font(.caption)
                    .foregroundStyle(option.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(option.surface, in: RoundedRectangle(cornerRadius: 8))

            HStack(spacing: 6) {
                ForEach([option.background, option.surface, option.accent], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .overlay {
                            Circle().strokeBorder(.primary.opacity(0.18), lineWidth: 1)
                        }
                        .frame(width: 16, height: 16)
                }
            }
            .accessibilityHidden(true)
        }
        .padding(12)
        .foregroundStyle(.primary)
        .background(option.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(selection == option ? option.accent : Color.primary.opacity(0.2),
                              lineWidth: selection == option ? 2 : 1)
        }
        .environment(\.colorScheme, option.colorScheme)
    }
}
