// ARWardenclyffeView.swift

import SwiftUI
import ARKit
import RealityKit
import UIKit

struct ARWardenclyffeView: View {
    @EnvironmentObject private var locationManager: WardenclyffeLocationManager

    var body: some View {
        ZStack(alignment: .topLeading) {
            if ARWorldTrackingConfiguration.isSupported {
                WardenclyffeARViewContainer(isOnSite: locationManager.isOnSite)
                    .ignoresSafeArea()
            } else {
                Text("Augmented reality is not supported on this device.")
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.center)
            }

            overlay
        }
        .onAppear {
            // Location affects full-scale vs. tabletop, but AR works either way.
            locationManager.requestAccessIfNeeded()
        }
        .navigationBarTitle("AR Tower", displayMode: .inline)
    }

    private var overlay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AR Wardenclyffe Tower")
                .font(.headline)

            if locationManager.isOnSite {
                Text("You’re near Wardenclyffe! Move your device slowly to see a full-scale version of Tesla’s tower on the grounds. Double-tap the tower to energize it.")
                    .font(.caption)
            } else {
                Text("You’re exploring from home. A tabletop version of Tesla’s Wardenclyffe tower appears in front of you. Double-tap the tower to energize it and see it glow.")
                    .font(.caption)
            }

            if let message = locationManager.lastErrorDescription {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .cornerRadius(16)
        .padding()
    }
}

struct WardenclyffeARViewContainer: UIViewRepresentable {
    let isOnSite: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(isOnSite: isOnSite)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView

        // Configure AR session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = isOnSite ? [.horizontal] : []
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Build tower
        let towerRoot = WardenclyffeTowerFactory.makeTowerEntity(fullScale: isOnSite)
        WardenclyffeTowerFactory.setTower(towerRoot, energized: false)

        // Make the tower hittable for gestures
        towerRoot.generateCollisionShapes(recursive: true)

        context.coordinator.towerRoot = towerRoot
        context.coordinator.baseScale = isOnSite ? 1.0 : 0.03

        if isOnSite {
            // Full-scale tower anchored to a real horizontal plane
            let planeAnchor = AnchorEntity(plane: .horizontal, minimumBounds: [1.0, 1.0])
            planeAnchor.addChild(towerRoot)
            arView.scene.addAnchor(planeAnchor)
        } else {
            // Tabletop tower positioned in front of the camera
            let cameraAnchor = AnchorEntity(world: [0, -0.4, -1.8])
            cameraAnchor.addChild(towerRoot)
            arView.scene.addAnchor(cameraAnchor)
        }

        // Double-tap gesture
        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        arView.addGestureRecognizer(doubleTap)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // If needed in the future, you could respond to isOnSite changes here.
    }

    // MARK: - Coordinator

    class Coordinator: NSObject {
        weak var arView: ARView?
        var towerRoot: Entity?
        var isOnSite: Bool
        var isEnergized = false
        var baseScale: Float = 1.0

        init(isOnSite: Bool) {
            self.isOnSite = isOnSite
        }

        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard
                let arView,
                let towerRoot
            else { return }

            let tapLocation = recognizer.location(in: arView)

            // Hit-test against entities in the scene (needs collision shapes)
            if let hitEntity = arView.entity(at: tapLocation),
               hitEntity.isDescendant(ofNamed: WardenclyffeTowerFactory.rootName) {

                isEnergized.toggle()
                WardenclyffeTowerFactory.setTower(towerRoot, energized: isEnergized)

                // Subtle pulse animation
                var transform = towerRoot.transform
                let targetScale = isEnergized ? baseScale * 1.05 : baseScale
                transform.scale = SIMD3<Float>(repeating: targetScale)

                towerRoot.move(
                    to: transform,
                    relativeTo: towerRoot.parent,
                    duration: 0.25,
                    timingFunction: .easeInOut
                )

                // Optional: tiny haptic
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}
