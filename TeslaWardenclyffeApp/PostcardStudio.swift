//
//  PostcardStudio.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


import SwiftUI

// MARK: - Postcard generator (no external deps)

struct PostcardStudio: View {
    @EnvironmentObject private var progress: WardenclyffeProgressStore
    @EnvironmentObject private var fx: InteractionKit

    let capturedImage: UIImage?

    @State private var quote: String = "“The present is theirs; the future, for which I really worked, is mine.”"
    @State private var stamp: String = "Wardenclyffe, NY"
    @State private var dateString: String = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)

    @State private var rendered: UIImage? = nil
    @State private var shareSheet: Bool = false

    var body: some View {
        VStack(spacing: 14) {
            postcardPreview
                .padding(.top)

            VStack(spacing: 10) {
                TextField("Stamp", text: $stamp).textFieldStyle(.roundedBorder)
                TextField("Quote", text: $quote, axis: .vertical).textFieldStyle(.roundedBorder)
                TextField("Date", text: $dateString).textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            HStack {
                Button("Render") {
                    fx.impact(.medium)
                    rendered = postcardPreviewImage()
                    progress.addPower(4, reason: "Postcard Render")
                    fx.notify(.success)
                }
                .buttonStyle(.borderedProminent)

                Button("Share") {
                    fx.impact(.light)
                    if rendered == nil { rendered = postcardPreviewImage() }
                    shareSheet = true
                    progress.addPower(2, reason: "Postcard Share")
                }
                .buttonStyle(.bordered)
                .disabled(capturedImage == nil)
            }
            .padding(.bottom)
        }
        .navigationTitle("Postcard Studio")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $shareSheet) {
            if let img = rendered {
                ActivityView(items: [img])
            }
        }
    }

    private var postcardPreview: some View {
        ZStack(alignment: .bottomLeading) {
            if let ui = capturedImage {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(.ultraThinMaterial)
                    VStack(spacing: 8) {
                        Image(systemName: "photo").font(.largeTitle)
                        Text("Add an AR snapshot to generate a postcard.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 6) {
                Text(stamp).font(.caption.weight(.semibold))
                Text(dateString).font(.caption2).opacity(0.9)
                Text(quote).font(.caption).lineLimit(3)
            }
            .foregroundStyle(.white)
            .padding()
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.12)))
        .padding(.horizontal)
    }

    private func postcardPreviewImage() -> UIImage? {
        let renderer = ImageRenderer(content: postcardPreview.padding(.horizontal, 0))
        renderer.scale = UIScreen.main.scale
        return renderer.uiImage
    }
}

// Simple share sheet helper
struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
