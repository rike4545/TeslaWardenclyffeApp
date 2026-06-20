//
//  GalleryItem.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/12/25.
//


import Foundation

struct GalleryItem: Identifiable, Hashable {
    let id: String
    let imageName: String         // Asset name (or use remote later)
    let title: String
    let caption: String
    let credit: String?
}

struct GalleryAlbum: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let items: [GalleryItem]
}

enum WardenclyffeGalleryData {
    // Keep this curated. Add real credits/licensing as you swap in actual photos.
    static let albums: [GalleryAlbum] = [
        GalleryAlbum(
            id: "restoration",
            title: "Restoration",
            subtitle: "Work, details, and behind-the-scenes progress.",
            systemImage: "hammer",
            items: [
                GalleryItem(id: "rest1", imageName: "Restoration_01", title: "Site Work", caption: "A glimpse of the restoration effort.", credit: nil),
                GalleryItem(id: "rest2", imageName: "Restoration_02", title: "Detail", caption: "Architecture and materials up close.", credit: nil),
            ]
        ),
        GalleryAlbum(
            id: "artifacts",
            title: "Artifacts & Documents",
            subtitle: "Blueprints, notes, and historical context.",
            systemImage: "doc.richtext",
            items: [
                GalleryItem(id: "doc1", imageName: "Artifacts_01", title: "Document", caption: "Primary-source style materials.", credit: nil),
                GalleryItem(id: "doc2", imageName: "Artifacts_02", title: "Blueprint", caption: "Zoom in to explore the details.", credit: nil),
                GalleryItem(id: "doc3", imageName: "PatentTrail", title: "Patent Trail", caption: "A visual guide to Tesla's invention themes.", credit: "Generated project artwork"),
                GalleryItem(id: "doc4", imageName: "WardenclyffeBlueprint", title: "Resonance Blueprint", caption: "A schematic-style view for the virtual lab.", credit: "Generated project artwork"),
            ]
        ),
        GalleryAlbum(
            id: "visit",
            title: "Visiting the Site",
            subtitle: "What you’ll see when you arrive.",
            systemImage: "location.viewfinder",
            items: [
                GalleryItem(id: "visit1", imageName: "Visit_01", title: "Approach", caption: "A visitor’s-eye view of the grounds.", credit: nil),
                GalleryItem(id: "visit2", imageName: "Visit_02", title: "On-site", caption: "Landmarks you can spot on arrival.", credit: nil),
                GalleryItem(id: "visit3", imageName: "WardenclyffeMuseum", title: "Museum Companion", caption: "Guide artwork for tours and on-site planning.", credit: "Generated project artwork"),
                GalleryItem(id: "visit4", imageName: "WardenclyffeNight", title: "Event Night", caption: "A night-sky event scene for programs and community moments.", credit: "Generated project artwork"),
            ]
        )
    ]

    static let featured: [GalleryItem] = [
        GalleryItem(id: "feat1", imageName: "Featured_01", title: "Wardenclyffe Grounds", caption: "Explore the site through images and stories.", credit: nil),
        GalleryItem(id: "feat2", imageName: "Featured_02", title: "Restoration Progress", caption: "See what’s changing and why it matters.", credit: nil),
        GalleryItem(id: "feat3", imageName: "Featured_03", title: "Artifacts & Context", caption: "Documents and details worth zooming into.", credit: nil),
        GalleryItem(id: "feat4", imageName: "WardenclyffeTower", title: "Tower Energy", caption: "AR-ready tower artwork for the home experience.", credit: "Generated project artwork"),
        GalleryItem(id: "feat5", imageName: "QuestPassport", title: "Quest Passport", caption: "Badges and certificate artwork for young explorers.", credit: "Generated project artwork"),
        GalleryItem(id: "feat6", imageName: "SupportImpact", title: "Support Impact", caption: "Artwork for restoration, education, and visitor support.", credit: "Generated project artwork"),
    ]
}
