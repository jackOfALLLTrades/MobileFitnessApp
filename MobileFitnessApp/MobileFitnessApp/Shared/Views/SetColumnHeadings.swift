import SwiftUI

struct SetColumnHeadings: View {
    let style: SetRowStyle

    var body: some View {
        SetRowLayout(style: style) {
            Text("SET")
        } previous: {
            Text("PREVIOUS")
        } weight: {
            Text("LBS")
        } reps: {
            Text("REPS")
        } completion: {
            Spacer()
        }
        .font(style.headingFont.weight(.semibold))
        .foregroundStyle(.secondary)
        .listRowSeparator(.hidden)
    }
}

