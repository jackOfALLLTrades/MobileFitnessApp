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
        SetRowLayout(style: .routine, showsWeight: showsWeight) {
            Text("\(number)")
                .font(.subheadline.weight(.medium))
        } previous: {
            EmptyView()
        } weight: {
            Text("—").foregroundStyle(.tertiary)
        } reps: {
            Text("—").foregroundStyle(.tertiary)
        } completion: {
            EmptyView()
        }
    }
}
