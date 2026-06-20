//
//  PhotoGalleryHubView.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/12/25.
//


import SwiftUI
import UIKit

struct PhotoGalleryHubView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Galleries")
                    .font(.title2.bold())
                    .padding(.horizontal)

                LazyVStack(spacing: 14) {
                    ForEach(WardenclyffeGalleryData.albums) { album in
                        NavigationLink {
                            GalleryAlbumView(album: album)
                        } label: {
                            HomeTile(
                                title: album.title,
                                subtitle: album.subtitle,
                                systemImage: album.systemImage
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .padding(.top, 8)
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Photos")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct GalleryAlbumView: View {
    let album: GalleryAlbum

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(album.items) { item in
                    NavigationLink {
                        PhotoViewerView(item: item)
                    } label: {
                        GalleryThumb(item: item)
                            .frame(height: 140)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PhotoViewerView: View {
    let item: GalleryItem

    var body: some View {
        VStack(spacing: 12) {
            ZoomableImage(imageName: item.imageName)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)

                Text(item.caption)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let credit = item.credit, !credit.isEmpty {
                    Text(credit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(.top, 10)
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: renderShareText(item)) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share")
            }
        }
    }

    private func renderShareText(_ item: GalleryItem) -> String {
        "\(item.title)\n\n\(item.caption)"
    }
}

struct FeaturedPhotoCard: View {
    let item: GalleryItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)

            GalleryImageOrPlaceholder(imageName: item.imageName, cornerRadius: 22)
                .opacity(0.92)

            LinearGradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.55)],
                           startPoint: .top,
                           endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(item.caption)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.88))
                    .lineLimit(2)
            }
            .padding(12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.caption)")
    }
}

struct GalleryThumb: View {
    let item: GalleryItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)

            GalleryImageOrPlaceholder(imageName: item.imageName, cornerRadius: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(item.caption)
                    .font(.caption2)
                    .foregroundStyle(Color.white.opacity(0.88))
                    .lineLimit(1)
            }
            .padding(10)
            .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.caption)")
    }
}

private struct GalleryImageOrPlaceholder: View {
    let imageName: String
    let cornerRadius: CGFloat

    var body: some View {
        if let ui = UIImage(named: imageName) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .clipped()
        } else {
            // Placeholder that looks intentional until you add Assets
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            WardenclyffeTheme.accent.opacity(0.22),
                            WardenclyffeTheme.accentSecondary.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(WardenclyffeTheme.accent.opacity(0.85))
                )
        }
    }
}
