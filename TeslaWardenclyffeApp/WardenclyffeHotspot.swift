//
//  WardenclyffeHotspot.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI

// MARK: - Hotspot content with swipe layers

struct WardenclyffeHotspot: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let layers: [HotspotLayer]
}

struct HotspotLayer: Identifiable, Hashable {
    let id = UUID()
    let kind: Kind
    let title: String
    let body: String

    enum Kind: String, Hashable {
        case context
        case mythVsFact
        case modernEquivalent
    }
}

struct HotspotsCarousel: View {
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var fx: InteractionKit

    let hotspots: [WardenclyffeHotspot]
    @State private var selected: WardenclyffeHotspot?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Explore Hotspots").font(.headline)
                Spacer()
                if progress.isUnlocked(.hotspotsBasics) {
                    Text("Unlocked").font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("Earn 10 Power").font(.caption).foregroundStyle(.secondary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hotspots) { h in
                        Button {
                            fx.impact(.light)
                            selected = h
                            progress.addPower(2, reason: "Hotspot Open")
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(h.title).font(.subheadline.weight(.semibold))
                                Text(h.subtitle).font(.caption).foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 220, alignment: .leading)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(.white.opacity(0.10)))
                        }
                        .buttonStyle(.plain)
                        .disabled(!progress.isUnlocked(.hotspotsBasics))
                        .opacity(progress.isUnlocked(.hotspotsBasics) ? 1 : 0.55)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .sheet(item: $selected) { h in
            HotspotDetailSheet(hotspot: h)
        }
    }
}

private struct HotspotDetailSheet: View {
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var fx: InteractionKit
    let hotspot: WardenclyffeHotspot

    @State private var idx: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TabView(selection: $idx) {
                    ForEach(Array(hotspot.layers.enumerated()), id: \.offset) { i, layer in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(layer.title).font(.title3.weight(.semibold))
                            Text(layer.body).foregroundStyle(.secondary)
                            Spacer(minLength: 0)
                            Label("Swipe for more", systemImage: "hand.draw")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .tag(i)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .onChange(of: idx) { _, _ in
                    fx.impact(.light)
                    progress.addPower(1, reason: "Hotspot Layer")
                }

                Button {
                    fx.notify(.success)
                    progress.addPower(3, reason: "Hotspot Completed")
                } label: {
                    Text("Mark as Explored")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(hotspot.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
