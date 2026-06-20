//
//  WardenclyffeARExperienceView.swift
//  TeslaWardenclyffeApp
//
//  Reliable placement on any flat surface (horizontal):
//  - ARWorldTrackingConfiguration + horizontal planeDetection
//  - Tap-to-place using raycast (existingPlaneGeometry first, then estimatedPlane fallback)
//  - ARCoachingOverlay guides scanning
//  - Drag / rotate / pinch gestures once placed (via ModelEntity proxy)
//

import SwiftUI
import UIKit
import RealityKit
import ARKit

@MainActor
struct WardenclyffeARExperienceView: View {

    // Keep compatibility if you already use WardenclyffeARExperienceView(isOnSite: ...)
    var isOnSite: Bool = true

    @Environment(\.dismiss) private var dismiss

    enum SurfaceState: Equatable {
        case searching
        case readyToPlace
        case placed
    }

    @State private var surfaceState: SurfaceState = .searching
    @State private var resetTick: Int = 0
    @State private var showResetConfirm: Bool = false

    var body: some View {
        ZStack {
            WardenclyffePlacementARContainer(
                surfaceState: $surfaceState,
                resetTick: $resetTick
            )
            .ignoresSafeArea()

            VStack {
                HStack(spacing: 12) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Spacer()

                    Button { showResetConfirm = true } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                Spacer()
            }

            VStack {
                Spacer()
                InstructionCard(state: surfaceState, isOnSite: isOnSite)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 22)
            }
        }
        .confirmationDialog("Reset AR session?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) { resetTick += 1 }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This clears the placed tower and re-scans the room.")
        }
    }
}

private struct InstructionCard: View {
    let state: WardenclyffeARExperienceView.SurfaceState
    let isOnSite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isOnSite {
                Text("Off-site mode")
                    .font(.headline)
                Text("You can still place the tower on a flat surface anywhere. Some on-site interactions may be limited.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider().opacity(0.25)
            }

            switch state {
            case .searching:
                Text("Find a flat surface")
                    .font(.headline)
                Text("Move your iPhone slowly so AR can detect a table or floor.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            case .readyToPlace:
                Text("Tap to place the Wardenclyffe Tower")
                    .font(.headline)
                Text("Aim at the surface and tap where you want it. If detection is still catching up, it will fall back to an estimated flat surface.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            case .placed:
                Text("Interact with the tower")
                    .font(.headline)
                Text("Drag to move • Twist to rotate • Pinch to scale\nTap another spot to reposition.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.18))
        )
    }
}

// MARK: - AR Container (unique name to avoid redeclaration conflicts)

private struct WardenclyffePlacementARContainer: UIViewRepresentable {
    @Binding var surfaceState: WardenclyffeARExperienceView.SurfaceState
    @Binding var resetTick: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(surfaceState: $surfaceState)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        let coaching = ARCoachingOverlayView()
        coaching.session = arView.session
        coaching.goal = .horizontalPlane
        coaching.activatesAutomatically = true
        coaching.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coaching)
        NSLayoutConstraint.activate([
            coaching.topAnchor.constraint(equalTo: arView.topAnchor),
            coaching.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
            coaching.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
            coaching.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
        ])

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)

        context.coordinator.attach(arView)
        context.coordinator.startSurfacePolling()

        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {
        context.coordinator.handleResetIfNeeded(resetTick: resetTick)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        @Binding private var surfaceState: WardenclyffeARExperienceView.SurfaceState

        private weak var arView: ARView?
        private var pollTimer: Timer?

        private var anchorEntity: AnchorEntity?

        // ✅ This is the gesture target: ModelEntity conforms to HasCollision
        private var interactiveRoot: ModelEntity?
        private var contentEntity: Entity?

        private var lastResetTick: Int = 0

        init(surfaceState: Binding<WardenclyffeARExperienceView.SurfaceState>) {
            self._surfaceState = surfaceState
        }

        func attach(_ arView: ARView) {
            self.arView = arView
        }

        func startSurfacePolling() {
            pollTimer?.invalidate()
            pollTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
                self?.pollForSurfaceAtScreenCenter()
            }
        }

        private func pollForSurfaceAtScreenCenter() {
            guard let arView else { return }
            guard surfaceState != .placed else { return }

            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let hits = arView.raycast(from: center, allowing: .existingPlaneGeometry, alignment: .horizontal)
            surfaceState = hits.isEmpty ? .searching : .readyToPlace
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView else { return }
            let point = recognizer.location(in: arView)

            var results = arView.raycast(from: point, allowing: .existingPlaneGeometry, alignment: .horizontal)
            if results.isEmpty {
                results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
            }

            guard let hit = results.first else {
                surfaceState = .searching
                return
            }

            placeOrMoveTower(worldTransform: hit.worldTransform)
        }

        private func placeOrMoveTower(worldTransform: simd_float4x4) {
            guard let arView else { return }

            // Anchor
            if anchorEntity == nil {
                let anchor = AnchorEntity(world: worldTransform)
                anchorEntity = anchor
                arView.scene.addAnchor(anchor)
            } else {
                anchorEntity?.transform.matrix = worldTransform
            }

            // Content + gestures (installed on ModelEntity proxy)
            if interactiveRoot == nil {
                // Load USDZ (Entity) or fallback placeholder (Entity)
                let content = Self.loadTowerEntityFallback()
                contentEntity = content

                // ✅ Proxy: ModelEntity => HasCollision
                let proxy = ModelEntity(
                    mesh: .generateSphere(radius: 0.0005),
                    materials: [SimpleMaterial(color: .clear, isMetallic: false)]
                )
                proxy.addChild(content)

                // Collisions required for gestures
                proxy.generateCollisionShapes(recursive: true)

                interactiveRoot = proxy
                anchorEntity?.addChild(proxy)

                // ✅ Compiles: proxy conforms to HasCollision
                arView.installGestures([.translation, .rotation, .scale], for: proxy)
            }

            surfaceState = .placed
        }

        func handleResetIfNeeded(resetTick: Int) {
            guard resetTick != lastResetTick else { return }
            lastResetTick = resetTick
            resetSession()
        }

        private func resetSession() {
            guard let arView else { return }

            pollTimer?.invalidate()
            pollTimer = nil

            interactiveRoot?.removeFromParent()
            interactiveRoot = nil

            contentEntity = nil

            anchorEntity?.removeFromParent()
            anchorEntity = nil

            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

            surfaceState = .searching
            startSurfacePolling()
        }

        // MARK: Model loading

        static func loadTowerEntityFallback() -> Entity {
            // If you have a USDZ in the bundle named "WardenclyffeTower.usdz",
            // this will load it as "WardenclyffeTower".
            if let entity = try? Entity.load(named: "WardenclyffeTower") {
                entity.position = .zero
                return entity
            }

            // Placeholder tower (always works)
            let pole = ModelEntity(
                mesh: .generateCylinder(height: 0.75, radius: 0.04),
                materials: [SimpleMaterial(color: .gray, isMetallic: true)]
            )
            pole.position = SIMD3(0, 0.375, 0)

            let cap = ModelEntity(
                mesh: .generateCone(height: 0.18, radius: 0.14),
                materials: [SimpleMaterial(color: .lightGray, isMetallic: true)]
            )
            cap.position = SIMD3(0, 0.84, 0)

            let base = ModelEntity(
                mesh: .generateBox(size: 0.30),
                materials: [SimpleMaterial(color: .darkGray, isMetallic: false)]
            )
            base.position = SIMD3(0, 0.15, 0)

            let root = Entity()
            root.addChild(base)
            root.addChild(pole)
            root.addChild(cap)
            return root
        }
    }
}
