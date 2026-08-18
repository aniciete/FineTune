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

    private let capsuleHeight: CGFloat = DesignTokens.Dimensions.sliderCapsuleHeight
    private let cornerRadius: CGFloat = DesignTokens.Dimensions.sliderCapsuleRadius

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
                // 1. Capsule Track Background (Frosted Translucent Glass)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isHovered ? DesignTokens.Colors.sliderCapsuleTrackHover : DesignTokens.Colors.sliderCapsuleTrack)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isHovered ? 0.12 : 0.08),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    }

                // 2. Unity Marker (at 50% / 100%)
                if showUnityMarker {
                    let unityPos = width * 0.5
                    Rectangle()
                        .fill(DesignTokens.Colors.unityMarker)
                        .frame(width: 1, height: capsuleHeight - 6)
                        .position(x: unityPos, y: capsuleHeight / 2)
                        .allowsHitTesting(false)
                }

                // 3. Filled Glass Capsule (Apple Control Center Luminous Fill)
                if fillWidth > 0 {
                    ZStack(alignment: .trailing) {
                        // Main luminous pill fill
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isHovered || isDragging ? 0.98 : 0.92),
                                        Color.white.opacity(isHovered || isDragging ? 0.90 : 0.84)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            // Subtle top specular highlight
                            .overlay(alignment: .top) {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.6),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 2)
                                    .padding(.horizontal, 4)
                            }
                    }
                    .frame(width: max(capsuleHeight, fillWidth), height: capsuleHeight)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(
                        color: Color.black.opacity(isDragging ? 0.25 : 0.12),
                        radius: isDragging ? 3 : 1.5,
                        x: 0,
                        y: 1
                    )
                }
            }
            .frame(height: capsuleHeight)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
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
