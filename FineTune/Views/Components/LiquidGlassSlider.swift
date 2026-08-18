// FineTune/Views/Components/LiquidGlassSlider.swift
import SwiftUI

/// A modern Apple Control Center style interactive capsule slider.
/// Features fluid gradient fills, tactile drag mechanics, unity detent markings,
/// and smooth hover illumination.
struct LiquidGlassSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let showUnityMarker: Bool
    let onEditingChanged: ((Bool) -> Void)?

    @State private var isDragging = false
    @State private var isHovered = false

    private let capsuleHeight: CGFloat = 11
    private let cornerRadius: CGFloat = 5.5

    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        showUnityMarker: Bool = false,
        onEditingChanged: ((Bool) -> Void)? = nil
    ) {
        self._value = value
        self.range = range
        self.showUnityMarker = showUnityMarker
        self.onEditingChanged = onEditingChanged
    }

    private var normalizedValue: Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        return (clamped - range.lowerBound) / span
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let fillWidth = max(0, min(width, width * CGFloat(normalizedValue)))

            ZStack(alignment: .leading) {
                // 1. Capsule Track (Restrained Translucent Material)
                Capsule()
                    .fill(Color.primary.opacity(isHovered ? 0.12 : 0.08))
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
                    }

                // 2. Unity Marker (subtle 50%/100% detent)
                if showUnityMarker {
                    let unityPos = width * 0.5
                    Rectangle()
                        .fill(Color.primary.opacity(0.25))
                        .frame(width: 1, height: capsuleHeight - 4)
                        .position(x: unityPos, y: capsuleHeight / 2)
                        .allowsHitTesting(false)
                }

                // 3. Filled Capsule (Apple Neutral Luminous Material)
                if fillWidth > 0 {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.primary.opacity(isHovered || isDragging ? 0.88 : 0.72),
                                    Color.primary.opacity(isHovered || isDragging ? 0.80 : 0.64)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: max(capsuleHeight, fillWidth), height: capsuleHeight)
                }
            }
            .frame(height: capsuleHeight)
            .contentShape(Capsule())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if !isDragging {
                            isDragging = true
                            onEditingChanged?(true)
                        }
                        let fraction = max(0.0, min(1.0, gesture.location.x / width))
                        let span = range.upperBound - range.lowerBound
                        let newValue = range.lowerBound + (Double(fraction) * span)
                        value = newValue
                    }
                    .onEnded { _ in
                        isDragging = false
                        onEditingChanged?(false)
                    }
            )
        }
        .frame(height: capsuleHeight)
        .onHover { hovering in
            withAnimation(DesignTokens.Animation.hover) {
                isHovered = hovering
            }
        }
        .animation(isDragging ? nil : DesignTokens.Animation.quick, value: normalizedValue)
    }
}

// MARK: - Preview

#Preview("Liquid Glass Slider") {
    struct PreviewWrapper: View {
        @State private var value: Double = 0.5

        var body: some View {
            VStack(spacing: 30) {
                LiquidGlassSlider(value: $value, showUnityMarker: true)
                    .frame(width: 200)

                Text("\(Int(value * 200))%")
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .background(Color.black)
        }
    }
    return PreviewWrapper()
}
