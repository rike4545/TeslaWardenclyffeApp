//
//  WardenclyffeARView.swift
//  TeslaWardenclyffeApp
//
//  Fast + crash-hardened AR tower placement with QUICK PLACE fallback.
//  - Tap to place (raycast). If no plane yet and Quick Place ON, place 1.2m in front of camera.
//  - Double tap callback (energize toggle in shell)
//  - Coaching overlay auto-disabled in Quick Place mode (so it doesn’t “force scanning”)
//  - Model cache + clone-on-place (prevents re-parenting crashes)
//  - Snapshot + safe teardown
//
//  Swift 6 • iOS 17+
//

import SwiftUI
import RealityKit
import ARKit
import UIKit

// MARK: - State

enum WardenclyffeARState: Equatable {
    case loadingModel
    case readyToPlace
    case placed
    case error(String)
}

// MARK: - Model Cache

@MainActor
final class WardenclyffeModelCache {

    static let shared = WardenclyffeModelCache()

    private var cache: [String: ModelEntity] = [:]
    private var inFlight: [String: Task<ModelEntity, Error>] = [:]

    private init() {}

    func preload(_ baseNames: [String]) async {
        for n in baseNames {
            _ = try? await modelTemplate(named: n)
        }
    }

    func modelTemplate(named baseName: String) async throws -> ModelEntity {
        if let cached = cache[baseName] { return cached }
        if let task = inFlight[baseName] { return try await task.value }

        let task = Task<ModelEntity, Error> {
            let entity = try await Self.loadModelEntityCompat(named: baseName)
            entity.generateCollisionShapes(recursive: true)
            entity.scale = SIMD3<Float>(repeating: 0.35)
            return entity
        }

        inFlight[baseName] = task
        do {
            let entity = try await task.value
            cache[baseName] = entity
            inFlight[baseName] = nil
            return entity
        } catch {
            inFlight[baseName] = nil
            throw error
        }
    }

    private static func loadModelEntityCompat(named name: String) async throws -> ModelEntity {
        if #available(iOS 18.0, *) {
            return try await ModelEntity(named: name, in: .main)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let model: ModelEntity = try Entity.loadModel(named: name, in: .main)
                        continuation.resume(returning: model)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

// MARK: - UIViewRepresentable

struct WardenclyffeARView: UIViewRepresentable {

    let modelName: String
    let quickPlaceEnabled: Bool

    @Binding var energized: Bool
    @Binding var intensity: Double

    @Binding var state: WardenclyffeARState
    @Binding var resetRequested: Bool

    @Binding var requestSnapshot: Bool
    var onSnapshot: (UIImage) -> Void
    var onSnapshotHandled: () -> Void

    var onDoubleTap: () -> Void

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.attach(to: arView)

        guard ARWorldTrackingConfiguration.isSupported else {
            DispatchQueue.main.async { self.state = .error("AR World Tracking isn’t supported on this device.") }
            return arView
        }

        // Crisper rendering (optional but helps)
        arView.renderOptions.insert([.disableCameraGrain, .disableMotionBlur, .disableDepthOfField])

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        config.isAutoFocusEnabled = true

        arView.session.delegate = context.coordinator
        arView.session.run(config, options: [])

        // Coaching overlay (we hide it in Quick Place mode so it doesn’t “demand scanning”)
        let coaching = ARCoachingOverlayView()
        coaching.session = arView.session
        coaching.goal = .horizontalPlane
        coaching.activatesAutomatically = !quickPlaceEnabled
        coaching.translatesAutoresizingMaskIntoConstraints = false
        coaching.isHidden = quickPlaceEnabled
        arView.addSubview(coaching)
        NSLayoutConstraint.activate([
            coaching.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
            coaching.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
            coaching.topAnchor.constraint(equalTo: arView.topAnchor),
            coaching.bottomAnchor.constraint(equalTo: arView.bottomAnchor)
        ])
        context.coordinator.coachingOverlay = coaching
        context.coordinator.quickPlaceEnabled = quickPlaceEnabled

        // Gestures
        let singleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1

        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2

        singleTap.require(toFail: doubleTap)
        arView.addGestureRecognizer(singleTap)
        arView.addGestureRecognizer(doubleTap)

        // Initial model load
        context.coordinator.ensureModelIsLoaded(modelName: modelName) { self.state = $0 }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.quickPlaceEnabled = quickPlaceEnabled
        context.coordinator.coachingOverlay?.isHidden = quickPlaceEnabled
        context.coordinator.coachingOverlay?.activatesAutomatically = !quickPlaceEnabled

        context.coordinator.ensureModelIsLoaded(modelName: modelName) { self.state = $0 }
        context.coordinator.applyEnergizeIfNeeded(energized: energized, intensity: intensity)

        if resetRequested {
            context.coordinator.resetScene { self.state = $0 }
            resetRequested = false
        }

        if requestSnapshot {
            uiView.snapshot(saveToHDR: false) { image in
                if let image { onSnapshot(image) }
                onSnapshotHandled()
            }
        }
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.cleanup()
        uiView.session.pause()
        uiView.scene.anchors.removeAll()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(energized: $energized, intensity: $intensity, onDoubleTap: onDoubleTap)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, ARSessionDelegate {

        weak var arView: ARView?
        weak var coachingOverlay: ARCoachingOverlayView?

        var quickPlaceEnabled: Bool = true

        @Binding private var energized: Bool
        @Binding private var intensity: Double
        private let onDoubleTap: () -> Void

        private var templateModel: ModelEntity?
        private var preparedInstance: ModelEntity? // pre-clone to make placement instant
        private var placedModel: ModelEntity?
        private var placedAnchor: AnchorEntity?

        private var loadTask: Task<Void, Never>?
        private var isLoading = false

        private var stateCallback: ((WardenclyffeARState) -> Void)?

        private var activeBaseName: String?
        private var targetBaseName: String?

        private var lastEnergized: Bool?
        private var lastIntensityBucket: Int = -1

        init(energized: Binding<Bool>, intensity: Binding<Double>, onDoubleTap: @escaping () -> Void) {
            _energized = energized
            _intensity = intensity
            self.onDoubleTap = onDoubleTap
        }

        func attach(to arView: ARView) {
            self.arView = arView
        }

        func cleanup() {
            loadTask?.cancel()
            loadTask = nil
        }

        // MARK: AR session recovery (avoid “random” ARKit failures becoming fatal)

        func session(_ session: ARSession, didFailWithError error: Error) {
            DispatchQueue.main.async {
                self.stateCallback?(.error("AR session failed: \(error.localizedDescription)"))
            }
            restartSession()
        }

        func sessionWasInterrupted(_ session: ARSession) {
            DispatchQueue.main.async {
                self.stateCallback?(.error("AR session interrupted. Return to the app to continue."))
            }
        }

        func sessionInterruptionEnded(_ session: ARSession) {
            restartSession()
        }

        private func restartSession() {
            guard let arView else { return }
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            config.environmentTexturing = .automatic
            config.isAutoFocusEnabled = true

            DispatchQueue.main.async {
                arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
                self.resetScene { _ in }
                self.stateCallback?(.readyToPlace)
            }
        }

        // MARK: Loading / swapping (Standard vs HD)

        func ensureModelIsLoaded(modelName rawName: String, onState: @escaping (WardenclyffeARState) -> Void) {
            self.stateCallback = onState

            let base = (rawName as NSString).deletingPathExtension

            if base == activeBaseName, templateModel != nil, !isLoading { return }
            if base == targetBaseName, isLoading { return }

            loadTask?.cancel()
            loadTask = nil

            resetScene { _ in }
            templateModel = nil
            preparedInstance = nil
            placedModel = nil
            lastEnergized = nil
            lastIntensityBucket = -1

            isLoading = true
            targetBaseName = base
            onState(.loadingModel)

            loadTask = Task { [weak self] in
                guard let self else { return }
                do {
                    // Resource existence check
                    let url = Bundle.main.url(forResource: base, withExtension: "usdz")
                        ?? Bundle.main.url(forResource: base, withExtension: "usd")
                    guard url != nil else {
                        await MainActor.run {
                            self.isLoading = false
                            onState(.error("Missing model in bundle: \(base).usdz (check Target Membership)"))
                        }
                        return
                    }

                    let template = try await WardenclyffeModelCache.shared.modelTemplate(named: base)
                    try Task.checkCancellation()

                    await MainActor.run {
                        guard self.targetBaseName == base else {
                            self.isLoading = false
                            return
                        }

                        self.templateModel = template
                        self.preparedInstance = template.clone(recursive: true) // make first tap instant
                        self.activeBaseName = base
                        self.isLoading = false
                        onState(.readyToPlace)
                    }
                } catch is CancellationError {
                    // normal during quick toggles
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        onState(.error("Failed to load model: \(error.localizedDescription)"))
                    }
                }
            }
        }

        // MARK: Placement

        func resetScene(onState: @escaping (WardenclyffeARState) -> Void) {
            placedAnchor?.removeFromParent()
            placedAnchor = nil
            placedModel = nil
            onState(templateModel == nil ? .loadingModel : .readyToPlace)
        }

        @objc func handleSingleTap(_ sender: UITapGestureRecognizer) {
            guard let arView else { return }
            guard let templateModel else { return }
            guard placedAnchor == nil else { return }

            // Try normal raycast first (best accuracy)
            let location = sender.location(in: arView)
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)

            let anchor: AnchorEntity

            if let first = results.first {
                anchor = AnchorEntity(world: first.worldTransform)
            } else if quickPlaceEnabled {
                // ✅ QUICK PLACE fallback: put it in front of the camera immediately
                anchor = AnchorEntity(world: quickPlaceTransform(arView: arView))
            } else {
                // No surface found and quick place off
                return
            }

            placedAnchor = anchor

            // Place a clone (never the template)
            let instance = preparedInstance ?? templateModel.clone(recursive: true)
            preparedInstance = nil
            placedModel = instance

            // Optional: cheap contact shadow to “ground” it
            addContactShadow(to: anchor)

            anchor.addChild(instance)
            arView.scene.addAnchor(anchor)

            arView.installGestures([.translation, .rotation, .scale], for: instance)

            stateCallback?(.placed)
            applyEnergizeIfNeeded(energized: energized, intensity: intensity, force: true)
        }

        @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            onDoubleTap()
        }

        private func quickPlaceTransform(arView: ARView) -> simd_float4x4 {
            // Camera looks toward -Z; translate -1.2m forward, slightly down
            let cam = arView.cameraTransform.matrix
            var t = matrix_identity_float4x4
            t.columns.3.z = -1.2
            t.columns.3.y = -0.10
            return simd_mul(cam, t)
        }

        private func addContactShadow(to anchor: AnchorEntity) {
            let shadowMesh = MeshResource.generateCylinder(height: 0.001, radius: 1.1)
            let shadowMat = SimpleMaterial(color: UIColor.black.withAlphaComponent(0.18), isMetallic: false)
            let shadow = ModelEntity(mesh: shadowMesh, materials: [shadowMat])
            shadow.name = "ContactShadow"
            shadow.position.y = 0.001
            anchor.addChild(shadow)
        }

        // MARK: Energize (optimized)

        func applyEnergizeIfNeeded(energized: Bool, intensity: Double, force: Bool = false) {
            guard let model = placedModel else { return }

            let bucket = Int(max(0, min(1, intensity)) * 20)
            if !force, lastEnergized == energized, lastIntensityBucket == bucket { return }
            lastEnergized = energized
            lastIntensityBucket = bucket

            let clamped = max(0.0, min(1.0, intensity))
            let lightIntensity: Float = energized ? (1500 + 4500 * Float(clamped)) : 0
            let emissiveBoost: Float = energized ? (0.8 + 2.2 * Float(clamped)) : 0.0

            let lightName = "WardenclyffeEnergizeLight"
            let lightEntity: Entity
            if let existing = model.findEntity(named: lightName) {
                lightEntity = existing
            } else {
                let e = Entity()
                e.name = lightName
                e.position = SIMD3<Float>(0, 0.9, 0)
                model.addChild(e)
                lightEntity = e
            }

            if energized {
                var comp = PointLightComponent()
                comp.intensity = lightIntensity
                comp.attenuationRadius = 3.5
                comp.color = .white
                lightEntity.components.set(comp)
            } else {
                lightEntity.components.remove(PointLightComponent.self)
            }

            model.visit { entity in
                guard var m = (entity as? ModelEntity)?.model else { return }
                m.materials = m.materials.map { mat in
                    guard var pbr = mat as? PhysicallyBasedMaterial else { return mat }
                    pbr.emissiveIntensity = emissiveBoost
                    return pbr
                }
                (entity as? ModelEntity)?.model = m
            }
        }
    }
}

private extension Entity {
    func visit(_ body: (Entity) -> Void) {
        body(self)
        for child in children { child.visit(body) }
    }
}
