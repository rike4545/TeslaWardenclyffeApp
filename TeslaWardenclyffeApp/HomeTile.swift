import SwiftUI

struct HomeTile: View {
    enum Size {
        case small, medium, large

        var minHeight: CGFloat {
            switch self {
            case .small: 86
            case .medium: 118
            case .large: 150
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .subheadline.weight(.semibold)
            case .medium: return .subheadline.weight(.semibold)
            case .large: return .headline.weight(.semibold)
            }
        }

        var subtitleFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var iconBox: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 44
            case .large: return 52
            }
        }

        var iconSymbol: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 20
            case .large: return 24
            }
        }
    }

    let title: String
    let subtitle: String?
    let systemImage: String
    var size: Size = .medium

    var badgeText: String? = nil
    var progress: Double? = nil
    var emphasized: Bool = false
    var accessorySystemImage: String? = nil

    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action {
                Button(action: action) { tileBody }
                    .buttonStyle(.plain)
            } else {
                tileBody
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityString)
    }

    private var tileBody: some View {
        HStack(alignment: .top, spacing: 12) {
            iconBadge

            VStack(alignment: .leading, spacing: 6) {
                // ✅ Title wraps instead of truncating
                Text(title)
                    .font(size.titleFont)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle, !subtitle.isEmpty {
                    // ✅ Subtitle wraps instead of truncating
                    Text(subtitle)
                        .font(size.subtitleFont)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .minimumScaleFactor(0.85)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let badgeText, !badgeText.isEmpty {
                    Text(badgeText.uppercased())
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
                        .padding(.top, 2)
                }
            }

            Spacer(minLength: 6)

            trailingAccessory
                .padding(.top, 2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: size.minHeight, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.thinMaterial))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(emphasized ? 0.20 : 0.10))
        )
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.12))
                )
                .frame(width: size.iconBox, height: size.iconBox)

            Image(systemName: systemImage)
                .font(.system(size: size.iconSymbol, weight: .semibold))
        }
        .padding(.top, 1)
    }

    private var trailingAccessory: some View {
        HStack(spacing: 10) {
            if let progress {
                HomeTileProgressRing(progress: progress)
            }
            if let accessorySystemImage {
                Image(systemName: accessorySystemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var accessibilityString: String {
        var parts: [String] = [title]
        if let subtitle { parts.append(subtitle) }
        if let badgeText { parts.append(badgeText) }
        if let progress { parts.append("Progress \(Int(progress * 100)) percent") }
        return parts.joined(separator: ", ")
    }
}

private struct HomeTileProgressRing: View {
    let progress: Double // 0...1

    var body: some View {
        let p = max(0, min(1, progress))
        ZStack {
            Circle()
                .strokeBorder(.white.opacity(0.12), lineWidth: 3)
                .frame(width: 28, height: 28)

            Circle()
                .trim(from: 0, to: p)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 28, height: 28)

            Text("\(Int(p * 100))")
                .font(.caption2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }
}
