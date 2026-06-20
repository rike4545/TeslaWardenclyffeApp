// WardenclyffeTheme.swift

import SwiftUI
import UIKit

enum WardenclyffeTheme {
    /// Primary accent: Wardenclyffe blue.
    static let accent = Color(red: 28/255, green: 126/255, blue: 214/255)

    /// Deep supporting color for gradients.
    static let accentSecondary = Color(red: 11/255, green: 23/255, blue: 44/255)

    /// Midnight tone used by AR tower and deep surfaces (alias to accentSecondary).
    static let midnight = accentSecondary

    /// Glow highlight for AR and accents.
    static let glow = Color(red: 165/255, green: 227/255, blue: 255/255)

    /// Atmospheric background gradient that adapts well to light and dark mode.
    static let background = LinearGradient(
        colors: [
            Color(.systemBackground),
            accent.opacity(0.06),
            Color(.secondarySystemBackground)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// A reusable glass-like card style that respects Dynamic Type and dark mode.
struct GlassCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? 16 : 20)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 12 : 14)
            .background(.regularMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: dynamicTypeSize.isAccessibilitySize ? 22 : 24,
                    style: .continuous
                )
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.45 : 0.12),
                radius: 18,
                x: 0,
                y: 10
            )
    }
}

extension View {
    /// Apply the Wardenclyffe glass card style to any content.
    func wardenclyffeGlassCard() -> some View {
        modifier(GlassCardStyle())
    }

    /// Standard section header: dynamic type, VoiceOver header trait.
    func wardenclyffeSectionHeader() -> some View {
        self
            .font(.title2.bold())
            .accessibilityAddTraits(.isHeader)
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
                    .lineLimit(2)
            }
            .padding(14)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.white.opacity(0.10)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}
