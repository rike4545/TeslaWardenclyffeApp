// OatmealFundraisingView.swift
// Tesla Science Center at Wardenclyffe
//
// Educational overview of the 2012–2014 fundraising story:
// - The Oatmeal’s “Let’s Build a Goddamn Tesla Museum” campaign
// - Grassroots donors + New York State match
// - Later support from Elon Musk / Tesla Motors
//
// This view is intended as neutral educational context and is not
// affiliated with or endorsed by Tesla, Inc. or Matthew Inman.

import SwiftUI

struct OatmealFundraisingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                storySection
                publicVsCorporateSection
                whyItMattersSection
            }
            .padding()
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Oatmeal Fundraising Story")
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“Let’s Build a Goddamn Tesla Museum”")
                .font(.title2.bold())

            Text("How a webcomic, thousands of donors, and later corporate support helped save Nikola Tesla’s last lab at Wardenclyffe.")
                .font(.body)
                .foregroundStyle(.secondary)

            Text("2012–2014 • Crowdfunding, state support, and private philanthropy")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var storySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Oatmeal Campaign")
                .font(.headline)

            Text("""
In 2012, Matthew Inman — creator of the webcomic “The Oatmeal” — launched an Indiegogo campaign called “Let’s Build a Goddamn Tesla Museum.” The goal was to help Tesla Science Center at Wardenclyffe purchase Nikola Tesla’s former laboratory site in Shoreham, New York, before it was redeveloped for commercial use.
""")
                .font(.body)

            Text("""
Within about a week, more than 33,000 supporters from around the world donated over $1.3 million. New York State agreed to match up to $850,000, allowing the nonprofit to reach the seller’s asking price and secure the property for a future museum and science center.
""")
                .font(.body)
                .foregroundStyle(.secondary)

            BulletList(items: [
                "Campaign name: “Let’s Build a Goddamn Tesla Museum” on Indiegogo",
                "Organizer: Matthew Inman (The Oatmeal), in partnership with Tesla Science Center at Wardenclyffe",
                "Backers: 30,000+ donors worldwide",
                "Funds: roughly $1.3–1.4 million via crowdfunding, plus a matching grant from New York State"
            ])
        }
    }

    private var publicVsCorporateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Public Support and Tesla Motors")
                .font(.headline)

            Text("""
Most of the early fundraising that allowed Wardenclyffe to be purchased came from individual donors responding to The Oatmeal campaign and from public matching funds provided by New York State. At that stage, the effort was primarily grassroots: fans of Nikola Tesla, readers of The Oatmeal, and supporters of science and history.
""")
                .font(.body)

            Text("""
In 2014, after The Oatmeal published another Tesla-themed comic and asked publicly for additional help, Elon Musk (founder of Tesla Motors, now Tesla, Inc.) stated that he would be “happy to help.” Tesla Science Center later announced that Musk pledged $1 million toward the museum and a Tesla charging station for the site.
""")
                .font(.body)
                .foregroundStyle(.secondary)

            BulletList(items: [
                "2012: Wardenclyffe property purchase made possible by crowdfunding plus state match",
                "2014: Elon Musk / Tesla pledges $1 million and a charging station to support the future museum",
                "Grassroots donors, public grants, and private philanthropy all play roles in the broader story"
            ])

            callout
        }
    }

    private var callout: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.bubble")
                .font(.title2)
                .foregroundStyle(WardenclyffeTheme.accent)

            VStack(alignment: .leading, spacing: 6) {
                Text("About the “lack of support” debate")
                    .font(.subheadline.bold())

                Text("""
Some supporters felt that a company named after Nikola Tesla might have provided earlier or larger support for the museum effort. Others note that corporate, state, and individual contributions arrived at different moments in the project’s life. This app presents the timeline so visitors can understand how many different people and organizations — from online donors to public agencies to Tesla — have contributed to Wardenclyffe.
""")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var whyItMattersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Why This Story Matters")
                .font(.headline)

            Text("""
The Oatmeal fundraising campaign is now a core chapter in the history of Tesla Science Center at Wardenclyffe. Without that surge of public support — amplified by media coverage and matched by New York State — Tesla’s last lab might not have been saved for future generations.
""")
                .font(.body)

            Text("""
Today, the site’s restoration and museum plans are powered by a blend of community donations, grants, philanthropic gifts, and corporate contributions. Understanding this mix helps visitors see that preserving history and building new science centers is rarely the work of any one person or company — it’s a shared effort over many years.
""")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Shared Components

private struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                        .font(.body)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
    }
}
