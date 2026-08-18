// FineTune/Views/Components/VUMeter.swift
import SwiftUI

/// A vertical VU meter visualization for audio levels
/// Shows 8 bars that light up based on audio level with peak hold
struct VUMeter: View {
    let level: Float
    var isMuted: Bool = false

    @State private var animatedLevel: Float = 0

    private let meterWidth: CGFloat = 3
    private let meterHeight: CGFloat = 20

    var body: some View {
        ZStack(alignment: .bottom) {
            // Track
            Capsule()
                .fill(Color.primary.opacity(0.06))
                .frame(width: meterWidth, height: meterHeight)

            // Active level fill
            if !isMuted && animatedLevel > 0.01 {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green,
                                animatedLevel > 0.6 ? Color.yellow : Color.green,
                                animatedLevel > 0.85 ? Color.orange : Color.yellow
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: meterWidth, height: max(meterWidth, meterHeight * CGFloat(min(1.0, animatedLevel))))
                    .shadow(color: Color.green.opacity(0.4), radius: 2, y: 0)
            }
        }
        .frame(width: meterWidth, height: meterHeight)
        .onChange(of: level) { _, newLevel in
            withAnimation(.spring(response: 0.15, dampingFraction: 0.75)) {
                animatedLevel = newLevel
            }
        }
    }
}

// MARK: - Previews

#Preview("VU Meter - Vertical") {
    ComponentPreviewContainer {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("0%")
                    .font(.caption)
                VUMeter(level: 0)
            }

            HStack {
                Text("25%")
                    .font(.caption)
                VUMeter(level: 0.25)
            }

            HStack {
                Text("50%")
                    .font(.caption)
                VUMeter(level: 0.5)
            }

            HStack {
                Text("75%")
                    .font(.caption)
                VUMeter(level: 0.75)
            }

            HStack {
                Text("100%")
                    .font(.caption)
                VUMeter(level: 1.0)
            }
        }
    }
}

#Preview("VU Meter - Animated") {
    struct AnimatedPreview: View {
        @State private var level: Float = 0

        var body: some View {
            ComponentPreviewContainer {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    VUMeter(level: level)

                    Slider(value: Binding(
                        get: { Double(level) },
                        set: { level = Float($0) }
                    ))
                }
            }
        }
    }
    return AnimatedPreview()
}
