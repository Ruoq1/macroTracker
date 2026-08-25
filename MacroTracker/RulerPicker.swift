import SwiftUI

struct RulerPicker: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var majorEvery: Int = 5
    var tickSpacing: CGFloat = 14
    var minorHeight: CGFloat = 16
    var majorHeight: CGFloat = 34
    var minimumDragDistance: CGFloat = 6
    var onDragging: ((Bool) -> Void)? = nil
    var onCommit: ((Double) -> Void)? = nil

    @State private var dragAnchor: Double?

    private var tickValues: [Double] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
    }

    var body: some View {
        GeometryReader { geo in
            let centerX = geo.size.width / 2
            ZStack {
                HStack(spacing: 0) {
                    ForEach(tickValues, id: \.self) { tick in
                        tickView(for: tick)
                            .frame(width: tickSpacing)
                    }
                }
                .offset(x: centerX - CGFloat((value - range.lowerBound) / step) * tickSpacing - tickSpacing / 2)

                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: minimumDragDistance)
                    .onChanged { gesture in
                        if dragAnchor == nil {
                            dragAnchor = value
                            onDragging?(true)
                        }
                        let anchor = dragAnchor ?? value
                        let raw = anchor - gesture.translation.width / tickSpacing * step
                        let clamped = min(max(raw, range.lowerBound), range.upperBound)
                        value = (clamped / step).rounded() * step
                    }
                    .onEnded { _ in
                        dragAnchor = nil
                        onDragging?(false)
                        onCommit?(value)
                    }
            )
        }
        .sensoryFeedback(.selection, trigger: Int((value / step).rounded()))
    }

    @ViewBuilder
    private func tickView(for tick: Double) -> some View {
        let index = Int(((tick - range.lowerBound) / step).rounded())
        let isMajor = index % majorEvery == 0
        Rectangle()
            .fill(isMajor ? Color.primary.opacity(0.7) : Color.secondary.opacity(0.35))
            .frame(width: isMajor ? 2 : 1, height: isMajor ? majorHeight : minorHeight)
    }
}

#Preview {
    RulerPicker(value: .constant(45), range: 0...300)
        .frame(height: 90)
        .padding()
}
