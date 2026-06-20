// OnboardingView.swift

import SwiftUI

struct OnboardingFeature: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var pageIndex = 0

    private let features: [OnboardingFeature] = [
        OnboardingFeature(
            title: "Discover Wardenclyffe",
            subtitle: "Explore Tesla’s site, learn its history, and see the museum evolve over time.",
            systemImage: "sparkles"
        ),
        OnboardingFeature(
            title: "Go On-Site or Remote",
            subtitle: "Use the guide on campus or dive into Virtual Lab experiences from anywhere.",
            systemImage: "map"
        ),
        OnboardingFeature(
            title: "Collect Sparks",
            subtitle: "Earn Power, keep a streak, and unlock AR moments by engaging daily.",
            systemImage: "bolt.fill"
        )
    ]

    var body: some View {
        ZStack {
            WardenclyffeTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Welcome to Wardenclyffe")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                TabView(selection: $pageIndex) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        onboardingPage(feature)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 360)

                VStack(spacing: 12) {
                    Button {
                        if pageIndex < features.count - 1 {
                            withAnimation(.snappy) { pageIndex += 1 }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(pageIndex < features.count - 1 ? "Continue" : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(WardenclyffeTheme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .foregroundStyle(.white)
                    }

                    Button("Skip") {
                        onComplete()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
    }

    private func onboardingPage(_ feature: OnboardingFeature) -> some View {
        VStack(spacing: 16) {
            Image(systemName: feature.systemImage)
                .font(.system(size: 52, weight: .semibold))
                .frame(width: 100, height: 100)
                .background(WardenclyffeTheme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .foregroundStyle(WardenclyffeTheme.accent)

            Text(feature.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(feature.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.12))
        )
        .padding(.horizontal, 6)
    }
}
