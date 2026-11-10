//
//  SetRowLayout.swift
//  MobileFitnessApp
//
//  Created by Brooks Coleman on 11/5/26.
//

import SwiftUI

/// Keeps set columns aligned in the routine editor and active workout.
struct SetRowLayout<Number: View, Previous: View, Weight: View, Reps: View, Completion: View>: View {
    let showsWeight: Bool
    @ViewBuilder let number: () -> Number
    @ViewBuilder let previous: () -> Previous
    @ViewBuilder let weight: () -> Weight
    @ViewBuilder let reps: () -> Reps
    @ViewBuilder let completion: () -> Completion

    var body: some View {
        HStack(spacing: 8) {
            number()
                .frame(width: 30)
                .padding(.leading, 4)

            previous().frame(width: 82)

            if showsWeight {
                weight().frame(maxWidth: .infinity)
            }
            reps().frame(maxWidth: .infinity)

            completion().frame(width: 28)
        }
    }
}

