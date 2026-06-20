//
//  TeslaPatentsView.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/11/25.
//


// TeslaPatentsView.swift
// Tesla Science Center at Wardenclyffe
//
// Searchable overview of Nikola Tesla's patents and the story of
// what happened with royalties and unprotected ideas.

import SwiftUI

struct TeslaPatentsView: View {
    @State private var searchText: String = ""

    private let patents = TeslaPatentInfo.sampleData

    private var filteredPatents: [TeslaPatentInfo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return patents }

        return patents.filter { $0.matches(search: query) }
    }

    var body: some View {
        List {
            introductionSection

            storySection

            Section {
                if filteredPatents.isEmpty {
                    Text("No results. Try searching for a different word, such as “motor”, “wireless”, or a year like 1893.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                } else {
                    ForEach(filteredPatents) { patent in
                        PatentRow(patent: patent)
                    }
                }
            } header: {
                Text("Browse key patents")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
            }
        }
        .listStyle(.insetGrouped)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search titles, years, or topics"
        )
        .navigationTitle("Tesla’s Patents")
        .navigationBarTitleDisplayMode(.inline)
        .background(WardenclyffeTheme.background.ignoresSafeArea())
    }

    // MARK: Sections

    private var introductionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                WardenclyffeAssetBanner(
                    imageName: "PatentTrail",
                    title: "Tesla's Invention Trail",
                    subtitle: "From AC motors to wireless systems and remote control.",
                    height: 170
                )
                .padding(.bottom, 4)

                Text("Nikola Tesla held hundreds of patents around the world for motors, transformers, wireless systems, and more. Many other ideas, especially late in his life, were never patented at all.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("This page highlights a few of his most influential patents and invites you to explore how they shaped the modern world.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 4)
        }
    }

    private var storySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Patents, royalties & what was left unprotected")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Text("""
Early in his career, Tesla licensed his AC motor and polyphase power system to George Westinghouse, with royalties that could have made him extremely wealthy if paid over the long term. When Westinghouse later faced pressure from bankers and competitors, Tesla reportedly agreed to release the company from those ongoing royalty payments so that the AC system could survive and spread.
""")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("""
Over time, some of Tesla’s patents were bought outright, others expired, and still more ideas — especially ambitious wireless power projects and late-life concepts — were never patented at all. As a result, Tesla’s inventions helped define modern electrical engineering, but he personally saw only a fraction of the long-term financial value they created.
""")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Use the search box above to look for motors, wireless power, radio, remote control, or other areas you’re curious about.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Row View

struct PatentRow: View {
    let patent: TeslaPatentInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(patent.title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Text("\(patent.year)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let number = patent.patentNumber {
                Text(number)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Text(patent.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if !patent.area.isEmpty || !patent.keywords.isEmpty {
                HStack(spacing: 6) {
                    if !patent.area.isEmpty {
                        TagCapsule(label: patent.area)
                    }
                    ForEach(patent.keywords.prefix(3), id: \.self) { word in
                        TagCapsule(label: word)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct TagCapsule: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(.tertiarySystemBackground))
            )
            .foregroundStyle(.secondary)
    }
}

// MARK: - Model

struct TeslaPatentInfo: Identifiable {
    let id = UUID()
    let title: String
    let year: Int
    let patentNumber: String?
    let area: String
    let summary: String
    let keywords: [String]

    func matches(search query: String) -> Bool {
        let q = query.lowercased()
        return title.lowercased().contains(q)
        || area.lowercased().contains(q)
        || summary.lowercased().contains(q)
        || keywords.contains(where: { $0.lowercased().contains(q) })
        || String(year).contains(q)
    }

    static let sampleData: [TeslaPatentInfo] = [
        TeslaPatentInfo(
            title: "Polyphase Alternating-Current Motor",
            year: 1888,
            patentNumber: "e.g. US381,968 and related",
            area: "AC power & motors",
            summary: "A motor and system that use multiple out-of-phase alternating currents to create a rotating magnetic field, forming the backbone of practical AC power and modern industry.",
            keywords: ["motor", "polyphase", "AC", "rotating field"]
        ),
        TeslaPatentInfo(
            title: "System of Electrical Power Transmission",
            year: 1893,
            patentNumber: nil,
            area: "AC power transmission",
            summary: "Describes a complete system of generators, transformers, transmission lines, and motors designed to transmit electrical power efficiently over long distances.",
            keywords: ["transmission", "Niagara", "power system"]
        ),
        TeslaPatentInfo(
            title: "High-Frequency Transformer (Tesla Coil)",
            year: 1891,
            patentNumber: nil,
            area: "High voltage & wireless",
            summary: "A resonant transformer circuit that produces very high voltages and high-frequency currents, used in demonstrations, radio work, and experiments with wireless energy.",
            keywords: ["coil", "transformer", "high frequency"]
        ),
        TeslaPatentInfo(
            title: "Method of and Apparatus for Controlling Mechanism of Moving Vehicle",
            year: 1898,
            patentNumber: "Remote-control boat patent",
            area: "Radio & remote control",
            summary: "A system for wirelessly controlling the movements of a boat or vehicle at a distance, anticipating modern remote control and autonomous systems.",
            keywords: ["remote control", "boat", "radio"]
        ),
        TeslaPatentInfo(
            title: "System of Transmission of Electrical Energy",
            year: 1900,
            patentNumber: nil,
            area: "Wireless power",
            summary: "A proposal for transmitting electrical energy without wires using resonant circuits and the Earth itself as part of the conducting system.",
            keywords: ["wireless power", "resonance", "energy transmission"]
        ),
        TeslaPatentInfo(
            title: "Method of Regulating Apparatus for Producing Electric Currents of High Frequency",
            year: 1896,
            patentNumber: nil,
            area: "Radio & high-frequency",
            summary: "Techniques for controlling and stabilizing high-frequency current generators, important for early wireless and radio experiments.",
            keywords: ["regulation", "high frequency", "radio"]
        ),
        TeslaPatentInfo(
            title: "Electric Lighting and Arc Lamp Improvements",
            year: 1886,
            patentNumber: nil,
            area: "Lighting",
            summary: "Early patents on arc lighting and improved generators, forming the foundation of Tesla’s later breakthroughs in alternating-current systems.",
            keywords: ["lighting", "arc lamp", "generator"]
        ),
        TeslaPatentInfo(
            title: "Fluid Propulsion and Turbine Concepts",
            year: 1913,
            patentNumber: nil,
            area: "Mechanical & turbines",
            summary: "Patents related to Tesla’s disk turbine and ideas for efficient fluid-driven machinery, showing his interests beyond electrical systems.",
            keywords: ["turbine", "mechanical", "fluid"]
        )
    ]
}
