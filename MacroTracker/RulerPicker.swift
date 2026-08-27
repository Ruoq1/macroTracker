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

    var body: some View {
        GeometryReader { geo in
            let tickSpacing = geo.size.width / CGFloat(visibleTicks)
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let valueIndex = (value - range.lowerBound) / step

            ZStack {
                Canvas { context, size in
                    let halfCount = Int(size.width / tickSpacing / 2) + 2
                    let centerIndex = Int(valueIndex.rounded())

                    for i in (centerIndex - halfCount)...(centerIndex + halfCount) {
                        let tickValue = range.lowerBound + Double(i) * step
                        guard tickValue >= range.lowerBound, tickValue <= range.upperBound else { continue }

                        let x = centerX + (CGFloat(i) - valueIndex) * tickSpacing
                        let isMajor = i % majorEvery == 0
                        let h = isMajor ? majorHeight : minorHeight
                        let lineWidth: CGFloat = isMajor ? 2 : 1
                        let color = isMajor ? majorColor : Color.secondary.opacity(0.35)

                        var path = Path()
                        path.move(to: CGPoint(x: x, y: centerY - h / 2))
                        path.addLine(to: CGPoint(x: x, y: centerY + h / 2))
                        context.stroke(path, with: .color(color), lineWidth: lineWidth)
                    }
                }

                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
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
}

#Preview {
    RulerPicker(value: .constant(45), range: 0...300)
        .frame(height: 90)
        .padding()
}
