// FineTune/Views/Settings/Components/SettingsSection.swift
import SwiftUI

@MainActor
struct SettingsSection<Content: View>: View {
    private let title: String?
    @ViewBuilder private let content: () -> Content

    init(_ title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.sectionHeaderText)
                    .tracking(0.5)
                    .padding(.horizontal, 4)
            }
            VStack(spacing: 0) {
                content()
            }
            .glassIslandCard()
        }
    }
}
