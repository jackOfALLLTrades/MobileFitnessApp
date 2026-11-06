import SwiftUI

struct RoutineSetRow: View {
    let number: Int

    var body: some View {
        SetRowLayout(style: .routine) {
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
