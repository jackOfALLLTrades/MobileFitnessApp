//
//  DashboardView.swift
//  MobileFitnessApp
//
//  Created by Kaden Brooks on 10/22/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "dumbbell")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)

                Text("Welcome to Bodies")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Your workout journey starts here.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .themeBackground()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    DashboardView()
}
