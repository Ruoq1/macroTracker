import SwiftUI

struct RulerPicker: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double = 1
    var majorEvery: Int = 5
    var visibleTicks: Int = 20
    var minorHeight: CGFloat = 16
    var majorHeight: CGFloat = 34
    var majorColor: Color = .red
    var minimumDragDistance: CGFloat = 6
    var maxCoast: Double = 8
    var onDragging: ((Bool) -> Void)? = nil
    var onCommit: ((Double) -> Void)? = nil

    @State private var dragAnchor: Double?

    private var tickValues: [Double] {
        stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }
    }

    var body: some View {
        GeometryReader { geo in
            let tickSpacing = geo.size.width / CGFloat(visibleTicks)
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
                    .onEnded { gesture in
                        dragAnchor = nil

                        // Momentum: use the system's predicted end translation as a proxy for
                        // release velocity, but cap how far it can coast so it stays gentle.
                        let extraTranslation = gesture.predictedEndTranslation.width - gesture.translation.width
                        let rawExtra = -extraTranslation / tickSpacing * step
                        let clampedExtra = max(-maxCoast, min(maxCoast, rawExtra))
                        let target = min(max(value + clampedExtra, range.lowerBound), range.upperBound)
                        let snappedTarget = (target / step).rounded() * step

                        if snappedTarget != value {
                            withAnimation(.easeOut(duration: 0.35)) {
                                value = snappedTarget
                            } completion: {
                                onDragging?(false)
                                onCommit?(value)
                            }
                        } else {
                            onDragging?(false)
                            onCommit?(value)
                        }
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
            .fill(isMajor ? majorColor : Color.secondary.opacity(0.35))
            .frame(width: isMajor ? 2 : 1, height: isMajor ? majorHeight : minorHeight)
    }
}

#Preview {
    RulerPicker(value: .constant(45), range: 0...300)
        .frame(height: 90)
        .padding()
}
