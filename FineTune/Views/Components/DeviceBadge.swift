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
    let icon: NSImage?
    let isSelected: Bool
    var fallbackSymbol: String = "speaker.wave.2.fill"

    private let size: CGFloat = 24

    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.accentColor : Color.primary.opacity(0.12))

            Group {
                if let icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: 11.5, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(width: 13, height: 13)
            .foregroundStyle(isSelected ? Color.white : DesignTokens.Colors.textPrimary)
        }
        .frame(width: size, height: size)
        .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isSelected)
        .accessibilityHidden(true)
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
