//
//  SplashView.swift
//  MobileFitnessApp
//
//  Created by Ryan Domathoti on 11/9/26.
//


import SwiftUI

struct SplashView: View {

    var onFinish: () -> Void

    @State private var weightsOff = false
    @State private var barUp = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(barUp ? 0 : 1)
                .ignoresSafeArea()

            barbell
                .offset(y: barUp ? -900 : 0)
        }
        .task {
            try? await Task.sleep(for: .seconds(0.6))
            withAnimation(.easeIn(duration: 0.5)) { weightsOff = true }

            try? await Task.sleep(for: .seconds(0.7))
            withAnimation(.easeIn(duration: 0.6)) { barUp = true }

            try? await Task.sleep(for: .seconds(0.6))
            onFinish()
        }
    }

    // MARK: - Barbell

    private var barbell: some View {
        ZStack {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 240, height: 8)

            ForEach([-1.0, 1.0], id: \.self) { side in
                plate(width: 14, height: 76, x: 70, side: side)
                plate(width: 12, height: 52, x: 90, side: side)
            }
        }
    }

    private func plate(
        width: CGFloat,
        height: CGFloat,
        x: CGFloat,
        side: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.primary)
            .frame(width: width, height: height)
            .offset(x: side * (x + (weightsOff ? 160 : 0)))
            .opacity(weightsOff ? 0 : 1)
    }
}

#Preview {
    SplashView {}
}
