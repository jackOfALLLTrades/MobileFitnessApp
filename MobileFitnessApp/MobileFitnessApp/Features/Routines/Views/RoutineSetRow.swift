//
//  RoutineSetRow.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

struct RoutineSetRow: View {
    let number: Int
    let showsWeight: Bool

    var body: some View {
        SetRowLayout(showsWeight: showsWeight) {
            Text("\(number)")
                .font(.subheadline.weight(.medium))
        } previous: {
            Color.clear.frame(height: 1)
                .accessibilityHidden(true)
        } weight: {
            placeholder
        } reps: {
            placeholder
        } completion: {
            Image(systemName: "circle")
                .font(.title2)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 3)
    }

    private var placeholder: some View {
        Text("—")
            .foregroundStyle(.tertiary)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .accessibilityHidden(true)
    }
}
