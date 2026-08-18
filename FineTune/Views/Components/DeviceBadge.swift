// FineTune/Views/Components/DeviceBadge.swift
import SwiftUI
import AppKit

/// Circular tinted badge that replaces the leading radio button on a device row.
/// Selected state uses a gradient of `Color.accentColor` so it follows the user's
/// system accent at full scope. Unselected state uses a monochrome fill from
/// `DesignTokens.Colors.deviceBadgeMonoFill`.
///
/// The badge owns no behavior. The parent row container handles tap-to-set-default
/// via a row-level `TapGesture` so the click target spans the whole row, mirroring
/// the macOS Sound submenu pattern.
struct DeviceBadge: View {
    /// The device's icon image, if available. Falls back to `fallbackSymbol`.
    let icon: NSImage?
    /// Whether this row is the current default device.
    let isSelected: Bool
    /// SF Symbol name used when `icon` is nil. Defaults to a speaker glyph for
    /// output devices; input device rows pass `"mic"` so the fallback matches
    /// the row's domain.
    var fallbackSymbol: String = "speaker.wave.2.fill"

    private static let badgeSize: CGFloat = 26
    private static let cornerRadius: CGFloat = 6.5
    private static let glyphSize: CGFloat = 13

    var body: some View {
        ZStack {
            // Background fill — accent gradient when selected, mono glass fill otherwise.
            if isSelected {
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor,
                                Color.accentColor.opacity(0.85)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.10)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.75
                            )
                    }
                    .shadow(color: Color.accentColor.opacity(0.35), radius: 3, x: 0, y: 1)
            } else {
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .fill(DesignTokens.Colors.islandBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
                    }
            }

            // Glyph — device icon when present, fallback SF Symbol otherwise.
            Group {
                if let icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: Self.glyphSize, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(width: Self.glyphSize, height: Self.glyphSize)
            .foregroundStyle(glyphForeground)
        }
        .frame(width: Self.badgeSize, height: Self.badgeSize)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
        .accessibilityHidden(true)
    }

    private var glyphForeground: Color {
        isSelected
            ? Color.white
            : DesignTokens.Colors.textSecondary
    }
}

// MARK: - Previews

#Preview("DeviceBadge States") {
    HStack(spacing: 16) {
        VStack(spacing: 6) {
            DeviceBadge(icon: nil, isSelected: true)
            Text("Selected")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        VStack(spacing: 6) {
            DeviceBadge(icon: nil, isSelected: false)
            Text("Unselected")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    .padding()
    .frame(width: 200)
}
