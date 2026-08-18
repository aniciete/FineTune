// FineTune/Views/Components/BoostChevrons.swift
import SwiftUI

/// Stacked chevron boost indicator — 3 SF Symbol chevrons that light up based on boost level.
/// Click to cycle: 1x → 2x → 3x → 4x → 1x
struct BoostChevrons: View {
    let level: BoostLevel
    let onTap: () -> Void

    @State private var isHovered = false

    /// Number of lit chevrons for each boost level
    private var litCount: Int {
        switch level {
        case .x1: 0
        case .x2: 1
        case .x3: 2
        case .x4: 3
        }
    }

    /// Color for each chevron position (bottom=0, top=2)
    private func chevronColor(at index: Int) -> Color {
        if index < litCount {
            return DesignTokens.Colors.accentPrimary
        } else {
            return isHovered
                ? .primary.opacity(0.25)
                : .primary.opacity(0.15)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                Text(level.label)
                    .font(.system(size: 10, weight: level != .x1 ? .bold : .medium, design: .rounded))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background {
                Capsule()
                    .fill(
                        level != .x1
                            ? Color.accentColor.opacity(0.85)
                            : (isHovered ? DesignTokens.Colors.sliderCapsuleTrackHover : DesignTokens.Colors.boostInactiveBackground)
                    )
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        level != .x1
                            ? Color.accentColor
                            : (isHovered ? DesignTokens.Colors.glassBorderHover : DesignTokens.Colors.glassBorder),
                        lineWidth: 0.5
                    )
            }
            .foregroundStyle(
                level != .x1
                    ? Color.white
                    : (isHovered ? DesignTokens.Colors.interactiveHover : DesignTokens.Colors.boostInactiveForeground)
            )
            .shadow(
                color: level != .x1 ? Color.accentColor.opacity(0.4) : Color.clear,
                radius: 3,
                x: 0,
                y: 1
            )
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help("Volume boost: \(level.label) (click to cycle)")
        .accessibilityLabel("Volume boost \(level.label)")
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: level)
        .animation(DesignTokens.Animation.hover, value: isHovered)
    }
}

// MARK: - Previews

#Preview("Boost Chevrons") {
    ComponentPreviewContainer {
        HStack(spacing: DesignTokens.Spacing.lg) {
            VStack {
                BoostChevrons(level: .x1, onTap: {})
                Text("1x").font(.caption)
            }
            VStack {
                BoostChevrons(level: .x2, onTap: {})
                Text("2x").font(.caption)
            }
            VStack {
                BoostChevrons(level: .x3, onTap: {})
                Text("3x").font(.caption)
            }
            VStack {
                BoostChevrons(level: .x4, onTap: {})
                Text("4x").font(.caption)
            }
        }
    }
}
