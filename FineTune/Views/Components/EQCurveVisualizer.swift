// FineTune/Views/Components/EQCurveVisualizer.swift
import SwiftUI

/// A real-time spline curve visualization for the 10-band equalizer.
/// Renders an interpolated frequency response curve using Catmull-Rom spline
/// math with a dynamic accent gradient fill and 0 dB reference line.
struct EQCurveVisualizer: View {
    let bandGains: [Float]
    let isEnabled: Bool

    private let minDB: Float = -12.0
    private let maxDB: Float = 12.0

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let zeroY = height * 0.5

            ZStack {
                // Background Grid Lines
                gridLines(width: width, height: height, zeroY: zeroY)

                if bandGains.count == 10 {
                    let points = computeControlPoints(width: width, height: height)

                    // Filled Area Under Curve
                    curveFillPath(points: points, zeroY: zeroY, width: width)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(isEnabled ? 0.30 : 0.08),
                                    Color.accentColor.opacity(isEnabled ? 0.05 : 0.01)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    // Stroke Curve
                    curveStrokePath(points: points)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(isEnabled ? 0.8 : 0.25),
                                    Color.accentColor.opacity(isEnabled ? 1.0 : 0.35),
                                    Color.accentColor.opacity(isEnabled ? 0.8 : 0.25)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(
                            color: isEnabled ? Color.accentColor.opacity(0.4) : Color.clear,
                            radius: 3,
                            x: 0,
                            y: 0
                        )

                    // Control Point Dots
                    ForEach(0..<points.count, id: \.self) { i in
                        let pt = points[i]
                        Circle()
                            .fill(isEnabled ? Color.accentColor : Color.secondary.opacity(0.4))
                            .frame(width: 4, height: 4)
                            .position(pt)
                            .shadow(color: isEnabled ? Color.accentColor.opacity(0.6) : Color.clear, radius: 2)
                    }
                }
            }
        }
        .frame(height: 54)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .fill(DesignTokens.Colors.recessedBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius)
                .strokeBorder(DesignTokens.Colors.eqCardBorder, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Dimensions.buttonRadius))
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: bandGains)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }

    // MARK: - Grid Lines

    @ViewBuilder
    private func gridLines(width: CGFloat, height: CGFloat, zeroY: CGFloat) -> some View {
        Canvas { ctx, size in
            // +6 dB line
            let plus6Y = size.height * 0.25
            var p6 = Path()
            p6.move(to: CGPoint(x: 0, y: plus6Y))
            p6.addLine(to: CGPoint(x: size.width, y: plus6Y))
            ctx.stroke(p6, with: .color(DesignTokens.Colors.eqGridLine), lineWidth: 0.5)

            // -6 dB line
            let minus6Y = size.height * 0.75
            var m6 = Path()
            m6.move(to: CGPoint(x: 0, y: minus6Y))
            m6.addLine(to: CGPoint(x: size.width, y: minus6Y))
            ctx.stroke(m6, with: .color(DesignTokens.Colors.eqGridLine), lineWidth: 0.5)

            // 0 dB center reference line
            var zeroPath = Path()
            zeroPath.move(to: CGPoint(x: 0, y: zeroY))
            zeroPath.addLine(to: CGPoint(x: size.width, y: zeroY))
            ctx.stroke(zeroPath, with: .color(DesignTokens.Colors.eqZeroLine), lineWidth: 0.75)
        }
    }

    // MARK: - Point Computation

    private func computeControlPoints(width: CGFloat, height: CGFloat) -> [CGPoint] {
        let count = bandGains.count
        guard count > 1 else { return [] }

        return (0..<count).map { i in
            let gain = bandGains[i]
            let clamped = min(max(gain, minDB), maxDB)
            // Normalized: maxDB (+12) -> y = 0, minDB (-12) -> y = height
            let normalized = 1.0 - CGFloat((clamped - minDB) / (maxDB - minDB))
            let y = 6 + (normalized * (height - 12))

            // Evenly space x across the 10 bands matching EQSlider columns
            let step = width / CGFloat(count)
            let x = (CGFloat(i) * step) + (step * 0.5)

            return CGPoint(x: x, y: y)
        }
    }

    // MARK: - Spline Interpolation Paths

    private func curveStrokePath(points: [CGPoint]) -> Path {
        guard points.count > 1 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: 0, y: points[0].y))
        path.addLine(to: points[0])

        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = (i + 2 < points.count) ? points[i + 2] : p2

            // Catmull-Rom to Cubic Bézier conversion
            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6.0,
                y: p1.y + (p2.y - p0.y) / 6.0
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6.0,
                y: p2.y - (p3.y - p1.y) / 6.0
            )
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }

        if let last = points.last {
            path.addLine(to: CGPoint(x: points.last!.x + 20, y: last.y))
        }

        return path
    }

    private func curveFillPath(points: [CGPoint], zeroY: CGFloat, width: CGFloat) -> Path {
        guard points.count > 1 else { return Path() }
        var path = Path()
        let startX: CGFloat = 0
        path.move(to: CGPoint(x: startX, y: zeroY))
        path.addLine(to: CGPoint(x: startX, y: points[0].y))
        path.addLine(to: points[0])

        for i in 0..<(points.count - 1) {
            let p0 = i > 0 ? points[i - 1] : points[i]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = (i + 2 < points.count) ? points[i + 2] : p2

            let cp1 = CGPoint(
                x: p1.x + (p2.x - p0.x) / 6.0,
                y: p1.y + (p2.y - p0.y) / 6.0
            )
            let cp2 = CGPoint(
                x: p2.x - (p3.x - p1.x) / 6.0,
                y: p2.y - (p3.y - p1.y) / 6.0
            )
            path.addCurve(to: p2, control1: cp1, control2: cp2)
        }

        let endX = width
        if let last = points.last {
            path.addLine(to: CGPoint(x: endX, y: last.y))
        }
        path.addLine(to: CGPoint(x: endX, y: zeroY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Previews

#Preview("EQ Curve Visualizer") {
    VStack(spacing: 20) {
        EQCurveVisualizer(
            bandGains: [4, 6, 3, 0, -2, -1, 2, 5, 4, 3],
            isEnabled: true
        )
        .frame(width: 460)

        EQCurveVisualizer(
            bandGains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            isEnabled: true
        )
        .frame(width: 460)
    }
    .padding()
    .background(Color.black.opacity(0.8))
}
