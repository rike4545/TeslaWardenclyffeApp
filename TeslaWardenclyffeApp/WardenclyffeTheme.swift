// WardenclyffeTheme.swift

import SwiftUI
import UIKit

enum WardenclyffeTheme {
    static let accent = Color(red: 28/255, green: 126/255, blue: 214/255)
    static let accentSecondary = Color(red: 11/255, green: 23/255, blue: 44/255)
    static let midnight = accentSecondary
    static let glow = Color(red: 165/255, green: 227/255, blue: 255/255)

    static let background = LinearGradient(
        colors: [
            Color(.systemBackground),
            accent.opacity(0.05),
            Color(.secondarySystemBackground)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// Content surfaces stay intentionally flatter than controls.
/// On current Apple platforms, Liquid Glass is most effective for controls
/// layered above content rather than as a blanket treatment for every card.
struct WardenclyffeCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        let cornerRadius: CGFloat = dynamicTypeSize.isAccessibilitySize ? 22 : 24

        content
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 16 : 20)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 12 : 14)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.primary.opacity(colorScheme == .dark ? 0.10 : 0.06))
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08),
                radius: 14,
                x: 0,
                y: 7
            )
    }
}

extension View {
    /// Backward-compatible name used throughout the existing project.
    /// The visual treatment now follows Apple's current content-surface guidance.
    func wardenclyffeGlassCard() -> some View {
        modifier(WardenclyffeCardStyle())
    }

    func wardenclyffeSectionHeader() -> some View {
        self
            .font(.title2.bold())
            .accessibilityAddTraits(.isHeader)
    }

    /// Adopt iOS 27's scroll-responsive navigation bar while preserving
    /// compatibility with iOS 26.1, the app's current minimum deployment target.
    @ViewBuilder
    func wardenclyffeModernNavigationChrome() -> some View {
        if #available(iOS 27.0, *) {
            self.toolbarMinimizationBehavior(.onScrollDown, for: .navigationBar)
        } else {
            self
        }
    }
}

struct WardenclyffeAssetBanner: View {
    let imageName: String
    let title: String
    let subtitle: String
    var height: CGFloat = 190

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        WardenclyffeTheme.accent.opacity(0.30),
                        WardenclyffeTheme.accentSecondary.opacity(0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: "photo")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.24), .black.opacity(0.68)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.86))
                    .lineLimit(3)
            }
            .padding(14)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.10))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}
