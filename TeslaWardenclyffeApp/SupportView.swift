// SupportView.swift
// Tesla Science Center at Wardenclyffe

import SwiftUI

struct SupportView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var fx: InteractionKit
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @State private var selectedImpactAmount = 50.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Support Tesla Science Center")
                    .font(.largeTitle.bold())

                Text("Help restore Wardenclyffe and grow it into a transformative global science center inspired by Nikola Tesla’s bold spirit of invention.")
                    .font(.body)
                    .foregroundStyle(.secondary)

                WardenclyffeAssetBanner(
                    imageName: "SupportImpact",
                    title: "Every Spark Builds the Future",
                    subtitle: "Connect support to restoration, education, and visitor experiences."
                )

                // Capital campaign highlight
                if let campaign = appModel.involvementOptions.first(where: { $0.name.contains("Capital") }) {
                    SupportHighlightCard(option: campaign)
                }

                impactCalculator

                // Ways to get involved (grid)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Ways to Get Involved")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(appModel.involvementOptions) { option in
                            SupportOptionTile(option: option)
                        }
                    }
                }

                // New: Oatmeal + fundraising story linkage
                VStack(alignment: .leading, spacing: 8) {
                    Text("How the Museum Was Saved")
                        .font(.headline)

                    Text("Discover how The Oatmeal’s online campaign, thousands of donors, and later corporate gifts helped secure Wardenclyffe for a future museum and science center.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        OatmealFundraisingView()
                    } label: {
                        Label("Read the fundraising story", systemImage: "book.pages")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(.tertiarySystemBackground))
                            )
                    }
                }

                // Stay informed / mailing list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stay Informed")
                        .font(.headline)

                    Text("Sign up for news and updates to follow progress on the museum, programs, and events.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let url = URL(string: "https://teslasciencecenter.org/kiosk2b/") {
                        Link("Sign up for news & updates", destination: url)
                            .font(.subheadline.bold())
                    }
                }

                Spacer(minLength: 32)
            }
            .padding()
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Support")
    }

    private var impactCalculator: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Impact Calculator")
                        .font(.headline)
                    Text("Explore ways a contribution could support restoration, education, and visitor experiences.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text(selectedImpactAmount, format: .currency(code: "USD").precision(.fractionLength(0)))
                    .font(.title3.weight(.bold))
                    .monospacedDigit()
            }

            HStack(spacing: 8) {
                ForEach([25.0, 50.0, 100.0, 250.0], id: \.self) { amount in
                    Button {
                        selectedImpactAmount = amount
                        fx.impact(.light)
                    } label: {
                        Text(amount, format: .currency(code: "USD").precision(.fractionLength(0)))
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedImpactAmount == amount ? WardenclyffeTheme.accent : .secondary)
                }
            }

            Slider(value: $selectedImpactAmount, in: 10...500, step: 5)
                .tint(WardenclyffeTheme.accent)
                .accessibilityLabel("Donation amount")

            VStack(spacing: 10) {
                SupportImpactRow(
                    title: "Restoration Momentum",
                    detail: impactRestorationMessage,
                    systemImage: "hammer"
                )
                SupportImpactRow(
                    title: "STEM Programs",
                    detail: impactEducationMessage,
                    systemImage: "graduationcap"
                )
                SupportImpactRow(
                    title: "Visitor Experience",
                    detail: impactVisitorMessage,
                    systemImage: "person.2.wave.2"
                )
            }

            if let donateURL = URL(string: "https://teslasciencecenter.org/donate/") {
                Link(destination: donateURL) {
                    Label("Continue to donate", systemImage: "heart.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(WardenclyffeTheme.accent)
                .simultaneousGesture(TapGesture().onEnded {
                    progress.addPower(3, reason: "Support Intent")
                    fx.notify(.success)
                })
            }
        }
        .wardenclyffeGlassCard()
    }

    private var impactRestorationMessage: String {
        switch selectedImpactAmount {
        case ..<40:
            "Helps cover practical materials and small preservation needs."
        case ..<125:
            "Supports steady restoration work and behind-the-scenes site care."
        default:
            "Adds meaningful momentum to larger restoration and capital campaign goals."
        }
    }

    private var impactEducationMessage: String {
        switch selectedImpactAmount {
        case ..<40:
            "Can help supply hands-on learning materials for young inventors."
        case ..<125:
            "Can strengthen workshops, demos, and virtual learning activities."
        default:
            "Can help expand program reach for schools, families, and remote learners."
        }
    }

    private var impactVisitorMessage: String {
        switch selectedImpactAmount {
        case ..<40:
            "Contributes to clearer visitor materials and welcome resources."
        case ..<125:
            "Helps improve tours, signage, and interpretive experiences."
        default:
            "Can support richer exhibits and future visitor-center experiences."
        }
    }
}

// MARK: - Subviews

struct SupportHighlightCard: View {
    let option: InvolvementOption

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.name)
                .font(.title3.bold())

            Text(option.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let url = option.url {
                Link("Learn more", destination: url)
                    .font(.subheadline.bold())
            }
        }
        .wardenclyffeGlassCard()
    }
}

struct SupportOptionTile: View {
    let option: InvolvementOption

    var body: some View {
        Group {
            if let url = option.url {
                Link(destination: url) {
                    tileContent
                }
            } else {
                tileContent
            }
        }
    }

    private var tileContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(option.name)
                .font(.subheadline.bold())

            Text(option.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.08)))
    }
}

private struct SupportImpactRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(WardenclyffeTheme.accent.opacity(0.14), in: Circle())
                .foregroundStyle(WardenclyffeTheme.accent)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(.white.opacity(0.08)))
        .accessibilityElement(children: .combine)
    }
}
