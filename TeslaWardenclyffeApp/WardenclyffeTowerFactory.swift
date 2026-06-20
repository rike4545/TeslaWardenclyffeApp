// WardenclyffeTowerFactory.swift
// Stylized but historically-informed Wardenclyffe tower

import RealityKit
import SwiftUI

enum WardenclyffeTowerFactory {

    static let rootName = "wardenclyffe-tower"

    /// Build a stylized, historically-informed Wardenclyffe tower.
    /// - Parameter fullScale: true for on-site AR (large), false for tabletop.
    static func makeTowerEntity(fullScale: Bool) -> Entity {
        let root = Entity()
        root.name = rootName

        // Approx proportional constants (in meters):
        let baseHeight: Float = 1.0
        let supportHeight: Float = 56.0       // wooden frame height
        let domeRadius: Float = 10.5          // ~21m diameter

        let supportRadius: Float = 8.0        // radius of vertical supports
        let deckRadius: Float = 10.5          // deck beneath the dome

        // MARK: Base platform
        let baseMesh = MeshResource.generateCylinder(
            height: baseHeight,
            radius: deckRadius * 0.9
        )
        let baseEntity = ModelEntity(mesh: baseMesh, materials: [baseMaterial()])
        baseEntity.name = "tower-structure"
        baseEntity.position.y = baseHeight / 2
        root.addChild(baseEntity)

        // MARK: Wooden support frame (8 posts + ring beams)
        let legHeight: Float = supportHeight
        let legThickness: Float = 0.6
        let legMesh = MeshResource.generateBox(
            size: [legThickness, legHeight, legThickness]
        )

        let legCenterY = baseHeight + legHeight / 2
        let legCount = 8

        for i in 0..<legCount {
            let angle = Float(i) * 2 * .pi / Float(legCount)
            let x = cos(angle) * supportRadius
            let z = sin(angle) * supportRadius

            let leg = ModelEntity(mesh: legMesh, materials: [structureMaterial(energized: false)])
            leg.name = "tower-structure"
            leg.position = [x, legCenterY, z]
            root.addChild(leg)
        }

        // Ring beams to suggest lattice levels
        let lowerRingY = baseHeight + supportHeight * 0.35
        let upperRingY = baseHeight + supportHeight * 0.70

        let ringHeight: Float = 0.6
        let lowerRingMesh = MeshResource.generateCylinder(
            height: ringHeight,
            radius: supportRadius * 1.05
        )
        let upperRingMesh = MeshResource.generateCylinder(
            height: ringHeight,
            radius: deckRadius * 0.85
        )

        let lowerRing = ModelEntity(mesh: lowerRingMesh, materials: [structureMaterial(energized: false)])
        lowerRing.name = "tower-structure"
        lowerRing.position.y = lowerRingY
        root.addChild(lowerRing)

        let upperRing = ModelEntity(mesh: upperRingMesh, materials: [structureMaterial(energized: false)])
        upperRing.name = "tower-structure"
        upperRing.position.y = upperRingY
        root.addChild(upperRing)

        // MARK: Circular deck beneath dome
        let deckHeight: Float = 0.8
        let deckY = baseHeight + supportHeight * 0.85

        let deckMesh = MeshResource.generateCylinder(
            height: deckHeight,
            radius: deckRadius
        )
        let deck = ModelEntity(mesh: deckMesh, materials: [structureMaterial(energized: false)])
        deck.name = "tower-structure"
        deck.position.y = deckY
        root.addChild(deck)

        // MARK: Central conductor / coil
        let coilHeight: Float = deckY - baseHeight * 0.8
        let coilRadius: Float = 1.4

        let coilMesh = MeshResource.generateCylinder(
            height: coilHeight,
            radius: coilRadius
        )
        let coil = ModelEntity(mesh: coilMesh, materials: [coilMaterial(energized: false)])
        coil.name = "tower-coil"
        coil.position.y = baseHeight + coilHeight / 2
        root.addChild(coil)

        // MARK: Steel dome (hemispherical top)
        let domeMesh = MeshResource.generateSphere(radius: domeRadius)
        let dome = ModelEntity(mesh: domeMesh, materials: [domeMaterial(energized: false)])
        dome.name = "tower-dome"
        dome.position.y = deckY + domeRadius * 0.9
        root.addChild(dome)

        // Scale entire assembly for AR
        if fullScale {
            root.scale = SIMD3<Float>(repeating: 1.0)
        } else {
            root.scale = SIMD3<Float>(repeating: 0.03)
        }

        return root
    }

    /// Update material state across the tower when energized / idle.
    static func setTower(_ root: Entity, energized: Bool) {
        root.forEachDescendant { entity in
            guard let modelEntity = entity as? ModelEntity else { return }

            let newMaterial: SimpleMaterial

            switch entity.name {
            case "tower-structure":
                newMaterial = structureMaterial(energized: energized)
            case "tower-coil":
                newMaterial = coilMaterial(energized: energized)
            case "tower-dome":
                newMaterial = domeMaterial(energized: energized)
            default:
                return
            }

            // ModelComponent is a struct, so we must copy–modify–assign back
            if var component = modelEntity.model {
                component.materials = [newMaterial]
                modelEntity.model = component
            } else {
                // Fallback if there's somehow no model component
                modelEntity.model = ModelComponent(
                    mesh: modelEntity.model?.mesh ?? .generateSphere(radius: 0.1),
                    materials: [newMaterial]
                )
            }
        }
    }

    // MARK: - Materials

    private static func baseMaterial() -> SimpleMaterial {
        SimpleMaterial(
            color: UIColor.systemGray3,
            roughness: 0.9,
            isMetallic: false
        )
    }

    private static func structureMaterial(energized: Bool) -> SimpleMaterial {
        if energized {
            // Wooden frame lit by blue energy
            return SimpleMaterial(
                color: UIColor(WardenclyffeTheme.accent),
                roughness: 0.3,
                isMetallic: false
            )
        } else {
            // Neutral wooden tone
            return SimpleMaterial(
                color: UIColor.systemBrown,
                roughness: 0.8,
                isMetallic: false
            )
        }
    }

    private static func coilMaterial(energized: Bool) -> SimpleMaterial {
        if energized {
            return SimpleMaterial(
                color: UIColor(WardenclyffeTheme.glow),
                roughness: 0.1,
                isMetallic: true
            )
        } else {
            return SimpleMaterial(
                color: UIColor.systemGray4,
                roughness: 0.6,
                isMetallic: true
            )
        }
    }

    private static func domeMaterial(energized: Bool) -> SimpleMaterial {
        if energized {
            return SimpleMaterial(
                color: UIColor(WardenclyffeTheme.glow),
                roughness: 0.05,
                isMetallic: true
            )
        } else {
            // Steel dome in a dark, slightly reflective tone
            return SimpleMaterial(
                color: UIColor(WardenclyffeTheme.midnight),
                roughness: 0.5,
                isMetallic: true
            )
        }
    }
}

// MARK: - Helpers

extension Entity {
    /// Apply a closure to this entity and all descendants.
    func forEachDescendant(_ body: (Entity) -> Void) {
        body(self)
        for child in children {
            child.forEachDescendant(body)
        }
    }

    /// Returns true if this entity or any ancestor has the given name.
    func isDescendant(ofNamed name: String) -> Bool {
        if self.name == name { return true }
        return parent?.isDescendant(ofNamed: name) ?? false
    }
}
