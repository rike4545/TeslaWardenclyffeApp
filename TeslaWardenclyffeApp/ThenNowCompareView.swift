//
//  ThenNowCompareView.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/12/25.
//


import SwiftUI
import UIKit

struct ThenNowCompareView: View {
    let thenImageName: String
    let nowImageName: String
    let title: String

    @State private var reveal: CGFloat = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .padding(.horizontal)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    CompareImageOrPlaceholder(imageName: nowImageName)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                    CompareImageOrPlaceholder(imageName: thenImageName)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .mask(
                            Rectangle()
                                .frame(width: geo.size.width * reveal)
                        )
                        .clipped()

                    // Divider handle
                    Rectangle()
                        .frame(width: 2)
                        .foregroundStyle(.white.opacity(0.85))
                        .offset(x: geo.size.width * reveal - 1)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "arrow.left.and.right").font(.headline))
                        .offset(x: geo.size.width * reveal - 22)
                        .shadow(radius: 8, y: 6)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let x = max(0, min(geo.size.width, value.location.x))
                            reveal = x / geo.size.width
                        }
                )
            }
            .frame(height: 320)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Then")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Now")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                Slider(value: $reveal, in: 0...1)
            }
            .padding(.horizontal)

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
        .background(WardenclyffeTheme.background.ignoresSafeArea())
        .navigationTitle("Then vs Now")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CompareImageOrPlaceholder: View {
    let imageName: String
    var body: some View {
        if let ui = UIImage(named: imageName) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            LinearGradient(
                colors: [WardenclyffeTheme.accent.opacity(0.22), WardenclyffeTheme.accentSecondary.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundStyle(WardenclyffeTheme.accent.opacity(0.8)))
        }
    }
}
