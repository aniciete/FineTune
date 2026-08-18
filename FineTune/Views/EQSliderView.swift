// FineTune/Views/EQSliderView.swift
import SwiftUI

struct EQSliderView: View {
    let frequency: String
    @Binding var gain: Float
    let range: ClosedRange<Float> = -12...12

    // Local state for smooth visual updates
    @State private var localGain: Float = 0
    @State private var isDragging: Bool = false

    // Use design tokens for slider style variant support
    private var trackWidth: CGFloat { DesignTokens.Dimensions.sliderTrackHeight }
    private var thumbSize: CGFloat { DesignTokens.Dimensions.sliderThumbSize }
    private let tickCount = 5  // Number of tick marks
    private let tickWidth: CGFloat = 3
    private let tickGap: CGFloat = 3
    private let verticalPadding: CGFloat = 8

    private func formatGain(_ gain: Float) -> String {
        let rounded = Int(gain.rounded())
        return rounded >= 0 ? "+\(rounded)dB" : "\(rounded)dB"
    }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                let travelHeight = geo.size.height - (verticalPadding * 2)
                let normalizedGain = CGFloat((localGain - range.lowerBound) / (range.upperBound - range.lowerBound))
                let thumbY = verticalPadding + travelHeight * (1 - normalizedGain)

                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                let normalizedY = (value.location.y - verticalPadding) / travelHeight
                                let normalized = 1 - normalizedY
                                let clamped = min(max(normalized, 0), 1)
                                let newGain = Float(clamped) * (range.upperBound - range.lowerBound) + range.lowerBound
                                localGain = newGain
                                gain = newGain
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                    .scrollWheelStep($gain, in: range)
                    .overlay {
                        ZStack {
                            // Vertical Track Capsule
                            Capsule()
                                .fill(DesignTokens.Colors.sliderCapsuleTrack)
                                .frame(width: 4)

                            // 0 dB Center Baseline Marker
                            Rectangle()
                                .fill(DesignTokens.Colors.eqZeroLine)
                                .frame(width: 14, height: 1)
                                .position(x: geo.size.width / 2, y: geo.size.height / 2)

                            // Active Fill Bar from center (0 dB) to current value
                            let zeroY = geo.size.height / 2
                            let barHeight = abs(thumbY - zeroY)
                            let barY = min(thumbY, zeroY) + (barHeight / 2)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.accentColor,
                                            Color.accentColor.opacity(0.8)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4, height: max(4, barHeight))
                                .position(x: geo.size.width / 2, y: barY)

                            // Modern Tactile Knob
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 5, height: 5)
                            }
                            .frame(width: isDragging ? 15 : 13, height: isDragging ? 15 : 13)
                            .shadow(color: Color.black.opacity(0.35), radius: 2, y: 1)
                            .shadow(color: isDragging ? Color.accentColor.opacity(0.5) : Color.clear, radius: 4)
                            .position(x: geo.size.width / 2, y: thumbY)
                            .scaleEffect(isDragging ? 1.15 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isDragging)

                            // Floating dB Value Bubble
                            if isDragging {
                                Text(formatGain(localGain))
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background {
                                        Capsule().fill(Color.accentColor)
                                    }
                                    .shadow(color: Color.black.opacity(0.3), radius: 2, y: 1)
                                    .position(x: geo.size.width / 2, y: max(10, thumbY - 18))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .allowsHitTesting(false)
                    }
            }

            VStack(spacing: 1) {
                Text(frequency)
                    .font(DesignTokens.Typography.eqLabel)
                    .foregroundStyle(isDragging ? DesignTokens.Colors.textPrimary : DesignTokens.Colors.textSecondary)
                Text("Hz")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(DesignTokens.Colors.textTertiary)
            }
        }
        .onAppear {
            localGain = gain
        }
        .onChange(of: gain) { _, newValue in
            localGain = newValue
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        EQSliderView(frequency: "32", gain: .constant(6))
        EQSliderView(frequency: "1k", gain: .constant(0))
        EQSliderView(frequency: "16k", gain: .constant(-6))
    }
    .frame(width: 120, height: 120)
    .padding()
    .darkGlassBackground()
    .environment(\.colorScheme, .dark)
}
