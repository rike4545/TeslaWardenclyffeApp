 //
//  WardenclyffeARViewRepresentable.swift
//  TeslaWardenclyffeApp
//
//  Created by Bryan on 12/15/25.
//


//  WardenclyffeARViewRepresentable.swift
//  TeslaWardenclyffeApp
//
//  Drop-in ARView wrapper for WardenclyffeARExperienceView
//  - Tap to place once (until isPlaced reset to false)
//  - Removes anchor when isPlaced becomes false (re-place behavior)
//  - Applies TowerState (energized/intensity/frequency) to the placed entity
//  - Snapshot requests via NotificationCenter: .wardenclyffeARCapture
//  - Snapshot completion safely unwraps UIImage? before calling onCapture
//

import SwiftUI
import RealityKit
import ARKit

extension Notification.Name {
    static let wardenclyffeARCapture = Notification.Name("wardenclyffeARCapture")
}

struct WardenclyffeARViewRepresentable: UIViewRepresentable {
    let energyState: TowerEnergyState
    let intensity: Double
    let frequency: Double

    @Binding var isPlaced: Bool
    let onCapture: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Session configuration (safe defaults)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Tap to place
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tap.numberOfTapsRequired = 1
        arView.addGestureRecognizer(tap)

        context.coordinator.arView = arView
        context.coordinator.startObservingCaptureRequests()

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.sync(
            energyState: energyState,
            intensity: intensity,
            frequency: frequency,
            isPlaced: isPlaced
        )
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.stopObservingCaptureRequests()
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject {
        private let parent: WardenclyffeARViewRepresentable
        weak var arView: ARView?

        private var anchor: AnchorEntity?
        private var towerEntity: Entity?

        private var captureObserver: NSObjectProtocol?

        init(_ parent: WardenclyffeARViewRepresentable) {
            self.parent = parent
        }

        // MARK: Capture Requests

        func startObservingCaptureRequests() {
            captureObserver = NotificationCenter.default.addObserver(
                forName: .wardenclyffeARCapture,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.captureRequested()
            }
        }

        func stopObservingCaptureRequests() {
            if let captureObserver {
                NotificationCenter.default.removeObserver(captureObserver)
            }
            captureObserver = nil
        }

        private func captureRequested() {
            guard let arView else { return }

            // Some SDKs: completion is (UIImage?) -> Void
            arView.snapshot(saveToHDR: false) { [weak self] image in
                guard let self else { return }
                guard let image else { return } // ✅ unwrap optional
                self.parent.onCapture(image)
            }
        }

        // MARK: Placement

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView else { return }
            guard parent.isPlaced == false else { return } // place only when not placed

            let location = sender.location(in: arView)

            guard let result = arView
                .raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
                .first else { return }

            // Remove previous anchor if any (should be nil, but safe)
            if let existing = anchor {
                arView.scene.anchors.remove(existing)
                anchor = nil
                towerEntity = nil
            }

            let newAnchor = AnchorEntity(world: result.worldTransform)
            anchor = newAnchor

            let tower = makeTowerEntity()
            towerEntity = tower
            newAnchor.addChild(tower)

            arView.scene.addAnchor(newAnchor)

            DispatchQueue.main.async {
                self.parent.isPlaced = true
            }
        }

        // MARK: Sync State (called from updateUIView)

        func sync(
            energyState: TowerEnergyState,
            intensity: Double,
            frequency: Double,
            isPlaced: Bool
        ) {
            // If user requested re-place (isPlaced toggled false), remove anchor/entity.
            if !isPlaced {
                removeTower()
                return
            }

            // If placed, apply visual state updates.
            guard let towerEntity else { return }
            applyState(to: towerEntity, energyState: energyState, intensity: intensity, frequency: frequency)
        }

        private func removeTower() {
            guard let arView else { return }
            if let existing = anchor {
                arView.scene.anchors.remove(existing)
            }
            anchor = nil
            towerEntity = nil
        }

        // MARK: Visual Effects (placeholder but safe)

        private func applyState(
            to entity: Entity,
            energyState: TowerEnergyState,
            intensity: Double,
            frequency: Double
        ) {
            let energized = (energyState == .energized)

            // Scale reacts to energized/intensity
            let baseScale: Float = 0.35
            let boost: Float = energized ? Float(0.04 + 0.16 * intensity) : 0.0
            entity.transform.scale = SIMD3(repeating: baseScale + boost)

            // Frequency: gentle yaw “tuning” preview
            let yaw = Float((frequency - 0.5) * 0.40)
            entity.transform.rotation = simd_quatf(angle: yaw, axis: SIMD3(0, 1, 0))

            // Tint any SimpleMaterial model children
            tintModels(in: entity, energized: energized, intensity: intensity)
        }

        private func tintModels(in root: Entity, energized: Bool, intensity: Double) {
            root.visit { ent in
                guard let model = ent as? ModelEntity else { return }
                guard var mat = model.model?.materials.first as? SimpleMaterial else { return }

                if energized {
                    // brighter when energized; intensity increases alpha a bit
                    let a = CGFloat(0.70 + 0.30 * intensity)
                    mat.color.tint = UIColor(white: 1.0, alpha: a)
                } else {
                    mat.color.tint = UIColor(white: 1.0, alpha: 0.60)
                }

                model.model?.materials = [mat]
            }
        }

        // MARK: Tower Entity Factory (placeholder)

        /// Replace this with your real tower model loader (e.g. ModelEntity(named:) or your TowerFactory).
        private func makeTowerEntity() -> Entity {
            // Simple placeholder: cylinder + cap
            let base = ModelEntity(
                mesh: .generateCylinder(height: 0.60, radius: 0.10),
                materials: [SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.60), isMetallic: true)]
            )
            let cap = ModelEntity(
                mesh: .generateSphere(radius: 0.13),
                materials: [SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.70), isMetallic: true)]
            )
            cap.position = [0, 0.35, 0]

            let tower = Entity()
            tower.addChild(base)
            tower.addChild(cap)
            return tower
        }
    }
}

// MARK: - Entity traversal helper

private extension Entity {
    func visit(_ body: (Entity) -> Void) {
        body(self)
        for c in children { c.visit(body) }
    }
}
