import SceneKit
import SwiftUI

// MARK: - Flower 3D Scene Builder

enum Flower3DSceneBuilder {

    // MARK: - Public API

    static func buildScene(
        outerDesign: OuterPetalDesign,
        innerDesign: InnerPetalDesign,
        stamenDesign: StamenDesign,
        centerDesign: CenterDesign,
        outerColor: Color,
        innerColor: Color,
        stamenColor: Color,
        centerColor: Color,
        geometry: FlowerGeometry
    ) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(Color.appCream)

        let rootNode = scene.rootNode

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.position = SCNVector3(0, 1.2, 2.5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(cameraNode)

        // Lights
        addLighting(to: rootNode)

        // Flower
        let flowerRoot = SCNNode()
        flowerRoot.name = "flowerRoot"

        addPetals(
            to: flowerRoot,
            outerDesign: outerDesign,
            innerDesign: innerDesign,
            outerColor: outerColor,
            innerColor: innerColor,
            geometry: geometry
        )

        addStamen(
            to: flowerRoot,
            design: stamenDesign,
            color: stamenColor,
            geometry: geometry
        )

        addCenter(
            to: flowerRoot,
            design: centerDesign,
            color: centerColor,
            geometry: geometry
        )

        rootNode.addChildNode(flowerRoot)
        return scene
    }

    // MARK: - Lighting

    private static func addLighting(to root: SCNNode) {
        // Ambient
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.color = UIColor(white: 1.0, alpha: 1.0)
        ambientNode.light?.intensity = 300
        root.addChildNode(ambientNode)

        // Key light (upper-left)
        let keyNode = SCNNode()
        keyNode.light = SCNLight()
        keyNode.light?.type = .directional
        keyNode.light?.intensity = 800
        keyNode.light?.color = UIColor(white: 0.98, alpha: 1.0)
        keyNode.eulerAngles = SCNVector3(-Float.pi / 3, -Float.pi / 4, 0)
        root.addChildNode(keyNode)

        // Fill light (lower-right)
        let fillNode = SCNNode()
        fillNode.light = SCNLight()
        fillNode.light?.type = .directional
        fillNode.light?.intensity = 400
        fillNode.light?.color = UIColor(white: 0.95, alpha: 1.0)
        fillNode.eulerAngles = SCNVector3(Float.pi / 6, Float.pi / 3, 0)
        root.addChildNode(fillNode)
    }

    // MARK: - Petals

    private static func addPetals(
        to parent: SCNNode,
        outerDesign: OuterPetalDesign,
        innerDesign: InnerPetalDesign,
        outerColor: Color,
        innerColor: Color,
        geometry: FlowerGeometry
    ) {
        let outerParams = outerDesign.meshParams
        let innerParams = innerDesign.meshParams

        // Back outer petals (tilted further out)
        if geometry.backCount > 0 {
            let halfInterval = Float.pi / Float(max(geometry.backCount, 1))
            for i in 0..<geometry.backCount {
                let angle = Float(i) / Float(geometry.backCount) * 2 * Float.pi + halfInterval
                let petal = makePetalNode(
                    params: outerParams,
                    color: outerColor,
                    width: Float(geometry.petalWidth),
                    tiltAngle: -55 * Float.pi / 180,
                    yRotation: angle,
                    scale: 1.0
                )
                parent.addChildNode(petal)
            }
        }

        // Front outer petals
        if geometry.outerCount > 0 {
            for i in 0..<geometry.outerCount {
                let angle = Float(i) / Float(geometry.outerCount) * 2 * Float.pi
                let petal = makePetalNode(
                    params: outerParams,
                    color: outerColor,
                    width: Float(geometry.petalWidth),
                    tiltAngle: -35 * Float.pi / 180,
                    yRotation: angle,
                    scale: 1.0
                )
                parent.addChildNode(petal)
            }
        }

        // Inner petals (smaller, less tilted, offset 30 deg from outer)
        if geometry.innerCount > 0 {
            let offset = 30 * Float.pi / 180
            for i in 0..<geometry.innerCount {
                let angle = Float(i) / Float(geometry.innerCount) * 2 * Float.pi + offset
                let petal = makePetalNode(
                    params: innerParams,
                    color: innerColor,
                    width: Float(geometry.innerWidth),
                    tiltAngle: -20 * Float.pi / 180,
                    yRotation: angle,
                    scale: 0.7
                )
                parent.addChildNode(petal)
            }
        }
    }

    private static func makePetalNode(
        params: PetalMeshParams,
        color: Color,
        width: Float,
        tiltAngle: Float,
        yRotation: Float,
        scale: Float
    ) -> SCNNode {
        let petalGeometry = buildPetalGeometry(params: params, width: width, scale: scale)
        petalGeometry.materials = [clayMaterial(color: color)]

        let petalNode = SCNNode(geometry: petalGeometry)
        petalNode.eulerAngles.x = tiltAngle

        let wrapper = SCNNode()
        wrapper.eulerAngles.y = yRotation
        wrapper.addChildNode(petalNode)
        return wrapper
    }

    // MARK: - Petal Mesh Generation

    private static func buildPetalGeometry(
        params: PetalMeshParams,
        width: Float,
        scale: Float
    ) -> SCNGeometry {
        let uSteps = 8
        let vSteps = 12
        let uCount = uSteps + 1
        _ = vSteps + 1

        var positions: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var texCoords: [CGPoint] = []

        let petalLength: Float = 0.5 * scale
        let petalHalfWidth: Float = 0.22 * width * scale

        for vi in 0...vSteps {
            let v = Float(vi) / Float(vSteps)
            // Width profile: sin-shaped, widest around 40%
            let widthProfile = pow(sin(v * Float.pi), 1.0 / params.taperPower)

            for ui in 0...uSteps {
                let u = Float(ui) / Float(uSteps)
                let uCentered = 2 * u - 1 // -1 to 1

                // Base x/y positions
                let x = uCentered * petalHalfWidth * widthProfile
                var y = v * petalLength

                // Cupping: parabolic cross-section
                var z = params.cupDepth * scale * (1 - uCentered * uCentered) * v

                // Edge curl: edges lift more
                z += params.edgeCurl * scale * uCentered * uCentered * v

                // Tip curl: tip curves inward (downward in local space)
                y -= params.tipCurl * scale * v * v * v * 0.3
                z -= params.tipCurl * scale * v * v * v

                positions.append(SCNVector3(x, y, z))
                texCoords.append(CGPoint(x: CGFloat(u), y: CGFloat(v)))
            }
        }

        // Build face normals, then average at shared vertices
        normals = Array(repeating: SCNVector3(0, 0, 0), count: positions.count)
        var indices: [Int32] = []

        for vi in 0..<vSteps {
            for ui in 0..<uSteps {
                let bl = vi * uCount + ui
                let br = bl + 1
                let tl = bl + uCount
                let tr = tl + 1

                // Triangle 1: bl, tl, br
                indices.append(contentsOf: [Int32(bl), Int32(tl), Int32(br)])
                // Triangle 2: br, tl, tr
                indices.append(contentsOf: [Int32(br), Int32(tl), Int32(tr)])

                // Compute face normals and accumulate
                let n1 = faceNormal(positions[bl], positions[tl], positions[br])
                let n2 = faceNormal(positions[br], positions[tl], positions[tr])

                for idx in [bl, tl, br] {
                    normals[idx] = normals[idx] + n1
                }
                for idx in [br, tl, tr] {
                    normals[idx] = normals[idx] + n2
                }
            }
        }

        // Normalize
        normals = normals.map { $0.normalized() }

        let positionSource = SCNGeometrySource(vertices: positions)
        let normalSource = SCNGeometrySource(normals: normals)
        let texSource = SCNGeometrySource(textureCoordinates: texCoords)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)

        return SCNGeometry(sources: [positionSource, normalSource, texSource], elements: [element])
    }

    // MARK: - Materials

    private static func clayMaterial(color: Color) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(color)
        material.roughness.contents = 0.85
        material.metalness.contents = 0.0
        material.isDoubleSided = true
        return material
    }

    // MARK: - Stamen

    private static func addStamen(
        to parent: SCNNode,
        design: StamenDesign,
        color: Color,
        geometry: FlowerGeometry
    ) {
        let stamenGroup = SCNNode()
        stamenGroup.name = "stamenGroup"

        let config = design.stamenConfig
        let baseRadius = Float(geometry.stamenScale) * 0.5
        let material = clayMaterial(color: color)

        for i in 0..<config.count {
            let angle = Float(i) / Float(config.count) * 2 * Float.pi

            // Filament
            let filament = SCNCylinder(radius: CGFloat(config.filamentRadius), height: CGFloat(baseRadius))
            filament.radialSegmentCount = 6
            filament.materials = [material]

            let filamentNode = SCNNode(geometry: filament)
            filamentNode.position = SCNVector3(0, Float(baseRadius) / 2, 0)

            // Anther tip
            let anther = SCNSphere(radius: CGFloat(config.tipRadius))
            anther.segmentCount = 8
            anther.materials = [material]

            let antherNode = SCNNode(geometry: anther)
            antherNode.position = SCNVector3(0, Float(baseRadius), 0)

            let stamenUnit = SCNNode()
            stamenUnit.addChildNode(filamentNode)
            stamenUnit.addChildNode(antherNode)
            stamenUnit.eulerAngles.x = -20 * Float.pi / 180

            let wrapper = SCNNode()
            wrapper.eulerAngles.y = angle
            wrapper.addChildNode(stamenUnit)
            stamenGroup.addChildNode(wrapper)
        }

        parent.addChildNode(stamenGroup)
    }

    // MARK: - Center

    private static func addCenter(
        to parent: SCNNode,
        design: CenterDesign,
        color: Color,
        geometry: FlowerGeometry
    ) {
        let radius = Float(geometry.centerScale) * 0.6
        let sphere = SCNSphere(radius: CGFloat(radius))
        sphere.segmentCount = 24
        sphere.materials = [clayMaterial(color: color)]

        let centerNode = SCNNode(geometry: sphere)
        centerNode.name = "centerNode"
        centerNode.scale = SCNVector3(1, 0.5, 1) // Flatten to dome
        centerNode.position = SCNVector3(0, radius * 0.1, 0)
        parent.addChildNode(centerNode)
    }

    // MARK: - Vector Math

    private static func faceNormal(_ a: SCNVector3, _ b: SCNVector3, _ c: SCNVector3) -> SCNVector3 {
        let ab = b - a
        let ac = c - a
        return ab.cross(ac)
    }
}

// MARK: - Petal Mesh Parameters

fileprivate struct PetalMeshParams {
    let cupDepth: Float
    let taperPower: Float
    let edgeCurl: Float
    let tipCurl: Float
}

extension OuterPetalDesign {
    fileprivate var meshParams: PetalMeshParams {
        switch self {
        case .classic:       PetalMeshParams(cupDepth: 0.12, taperPower: 1.5, edgeCurl: 0.08, tipCurl: 0.05)
        case .rose:          PetalMeshParams(cupDepth: 0.25, taperPower: 1.2, edgeCurl: 0.03, tipCurl: 0.10)
        case .dahlia:        PetalMeshParams(cupDepth: 0.30, taperPower: 2.0, edgeCurl: 0.02, tipCurl: 0.02)
        case .peony:         PetalMeshParams(cupDepth: 0.15, taperPower: 1.3, edgeCurl: 0.15, tipCurl: 0.08)
        case .heartleaf:     PetalMeshParams(cupDepth: 0.10, taperPower: 1.0, edgeCurl: 0.05, tipCurl: 0.03)
        case .cosmos:        PetalMeshParams(cupDepth: 0.05, taperPower: 1.8, edgeCurl: 0.02, tipCurl: 0.01)
        case .round:         PetalMeshParams(cupDepth: 0.12, taperPower: 1.0, edgeCurl: 0.04, tipCurl: 0.06)
        case .cherryBlossom: PetalMeshParams(cupDepth: 0.08, taperPower: 1.0, edgeCurl: 0.03, tipCurl: 0.04)
        }
    }
}

extension InnerPetalDesign {
    fileprivate var meshParams: PetalMeshParams {
        switch self {
        case .tulip:   PetalMeshParams(cupDepth: 0.20, taperPower: 1.4, edgeCurl: 0.04, tipCurl: 0.06)
        case .star:    PetalMeshParams(cupDepth: 0.08, taperPower: 2.2, edgeCurl: 0.02, tipCurl: 0.01)
        case .bell:    PetalMeshParams(cupDepth: 0.28, taperPower: 1.1, edgeCurl: 0.06, tipCurl: 0.12)
        case .feather: PetalMeshParams(cupDepth: 0.06, taperPower: 1.8, edgeCurl: 0.10, tipCurl: 0.03)
        case .lotus:   PetalMeshParams(cupDepth: 0.15, taperPower: 1.2, edgeCurl: 0.03, tipCurl: 0.07)
        }
    }
}

// MARK: - Stamen Configuration

fileprivate struct StamenConfig {
    let count: Int
    let filamentRadius: Float
    let tipRadius: Float
}

extension StamenDesign {
    fileprivate var stamenConfig: StamenConfig {
        switch self {
        case .dewdrops:    StamenConfig(count: 8,  filamentRadius: 0.008, tipRadius: 0.018)
        case .fairyDust:   StamenConfig(count: 12, filamentRadius: 0.005, tipRadius: 0.012)
        case .sunburst:    StamenConfig(count: 16, filamentRadius: 0.008, tipRadius: 0.015)
        case .tendrils:    StamenConfig(count: 6,  filamentRadius: 0.010, tipRadius: 0.014)
        case .pollenCloud: StamenConfig(count: 10, filamentRadius: 0.006, tipRadius: 0.020)
        case .crown:       StamenConfig(count: 8,  filamentRadius: 0.012, tipRadius: 0.022)
        case .corona:      StamenConfig(count: 5,  filamentRadius: 0.010, tipRadius: 0.025)
        }
    }
}

// MARK: - SCNVector3 Math Extensions

private extension SCNVector3 {
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    func cross(_ other: SCNVector3) -> SCNVector3 {
        SCNVector3(
            y * other.z - z * other.y,
            z * other.x - x * other.z,
            x * other.y - y * other.x
        )
    }

    func normalized() -> SCNVector3 {
        let len = sqrt(x * x + y * y + z * z)
        guard len > 0.0001 else { return SCNVector3(0, 1, 0) }
        return SCNVector3(x / len, y / len, z / len)
    }
}
