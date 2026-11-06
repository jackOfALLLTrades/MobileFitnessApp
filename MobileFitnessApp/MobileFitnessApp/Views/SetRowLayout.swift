import SwiftUI

/// Keeps headings and rows aligned while preserving each screen's column sizes.
enum SetRowStyle {
    case routine
    case workout

    var spacing: CGFloat { self == .workout ? 8 : 12 }
    var numberWidth: CGFloat { self == .workout ? 30 : 44 }
    var numberAlignment: Alignment { self == .workout ? .center : .leading }
    var numberInset: CGFloat { self == .workout ? 4 : 0 }
    var headingFont: Font { self == .workout ? .caption2 : .caption }
}

struct SetRowLayout<Number: View, Previous: View, Weight: View, Reps: View, Completion: View>: View {
    let style: SetRowStyle
    @ViewBuilder let number: () -> Number
    @ViewBuilder let previous: () -> Previous
    @ViewBuilder let weight: () -> Weight
    @ViewBuilder let reps: () -> Reps
    @ViewBuilder let completion: () -> Completion

    var body: some View {
        HStack(spacing: style.spacing) {
            number()
                .frame(width: style.numberWidth, alignment: style.numberAlignment)
                .padding(.leading, style.numberInset)

            if style == .workout {
                previous()
                    .frame(width: 82, alignment: .center)
            }

            weight().frame(maxWidth: .infinity)
            reps().frame(maxWidth: .infinity)

            if style == .workout {
                completion().frame(width: 28)
            }
        }
    }
}

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
