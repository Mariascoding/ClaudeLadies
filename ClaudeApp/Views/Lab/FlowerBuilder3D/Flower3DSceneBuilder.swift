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
        geometry: FlowerGeometry,
        useToonShader: Bool = false
    ) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor(Color.appCream)

        let rootNode = scene.rootNode

        // Camera — pulled in close so the flower fills the frame
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 42
        cameraNode.position = SCNVector3(0, 0.85, 1.6)
        cameraNode.look(at: SCNVector3(0, 0.05, 0))
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
            geometry: geometry,
            useToonShader: useToonShader
        )

        addStamen(
            to: flowerRoot,
            design: stamenDesign,
            color: stamenColor,
            geometry: geometry,
            useToonShader: useToonShader
        )

        addCenter(
            to: flowerRoot,
            design: centerDesign,
            color: centerColor,
            geometry: geometry,
            useToonShader: useToonShader
        )

        // Bloom glow light (off by default)
        let bloomGlow = SCNNode()
        bloomGlow.name = "bloomGlow"
        bloomGlow.light = SCNLight()
        bloomGlow.light?.type = .omni
        bloomGlow.light?.color = UIColor(red: 1.0, green: 0.85, blue: 0.45, alpha: 1.0)
        bloomGlow.light?.intensity = 0
        bloomGlow.light?.attenuationStartDistance = 0
        bloomGlow.light?.attenuationEndDistance = 3.0
        bloomGlow.position = SCNVector3(0, 0.2, 0)
        flowerRoot.addChildNode(bloomGlow)

        // Sparkle nodes (hidden by default, animated in applyBloom)
        let sparkleGroup = SCNNode()
        sparkleGroup.name = "sparkleGroup"
        for i in 0..<20 {
            let theta = Float(i) / 20.0 * 2 * Float.pi + Float.random(in: -0.3...0.3)
            let r = Float.random(in: 0.3...0.6)

            let sphere = SCNSphere(radius: 0.008)
            sphere.segmentCount = 6
            let mat = SCNMaterial()
            mat.lightingModel = .constant
            mat.diffuse.contents = UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0)
            sphere.materials = [mat]

            let node = SCNNode(geometry: sphere)
            node.name = "sparkle_\(i)_\(theta)_\(r)"
            node.opacity = 0
            node.position = SCNVector3(r * cos(theta), 0, r * sin(theta))
            sparkleGroup.addChildNode(node)
        }
        flowerRoot.addChildNode(sparkleGroup)

        rootNode.addChildNode(flowerRoot)
        return scene
    }

    // MARK: - Bloom Animation

    static func applyBloom(to scene: SCNScene, progress: CGFloat, time: CGFloat) {
        guard let flowerRoot = scene.rootNode.childNode(withName: "flowerRoot", recursively: false) else { return }

        let p = min(max(Float(progress), 0), 1)
        let t = Float(time)

        // Derived time phases
        let breathPhase = t * 2.0
        let dancePhase = t * 0.6
        let danceAmount = min(max((p - 0.75) / 0.25, 0), 1)

        // Breath scale on flowerRoot (always active)
        let breathScale: Float = 1.0 + sin(breathPhase) * 0.015
        flowerRoot.scale = SCNVector3(breathScale, breathScale, breathScale)

        // Layer activation cascade (same timing as 2D)
        let centerProg = layerProgress(p, activationStart: 0.00, fullAt: 0.20)
        let stamenProg = layerProgress(p, activationStart: 0.08, fullAt: 0.30)
        let innerProg  = layerProgress(p, activationStart: 0.15, fullAt: 0.50)
        let frontProg  = layerProgress(p, activationStart: 0.25, fullAt: 0.65)
        let backProg   = layerProgress(p, activationStart: 0.35, fullAt: 0.80)

        // Enhanced bloom angles — extra open at 80%+
        let extraOpen = min(max((p - 0.8) / 0.2, 0), 1)

        // Back outer petals
        if let group = flowerRoot.childNode(withName: "backOuterGroup", recursively: false) {
            let s: Float = 0.1 + backProg * 0.9
            group.scale = SCNVector3(s, s, s)
            group.opacity = CGFloat(0.6 + backProg * 0.4)
            let openAngle: Float = -55 - extraOpen * 12
            applyPetalSway(group, closedAngle: -5, openAngle: openAngle, progress: backProg, dancePhase: dancePhase, danceAmount: danceAmount)
        }

        // Front outer petals
        if let group = flowerRoot.childNode(withName: "frontOuterGroup", recursively: false) {
            let s: Float = 0.1 + frontProg * 0.9
            group.scale = SCNVector3(s, s, s)
            group.opacity = CGFloat(0.6 + frontProg * 0.4)
            let openAngle: Float = -35 - extraOpen * 15
            applyPetalSway(group, closedAngle: -5, openAngle: openAngle, progress: frontProg, dancePhase: dancePhase, danceAmount: danceAmount)
        }

        // Inner petals
        if let group = flowerRoot.childNode(withName: "innerGroup", recursively: false) {
            let s: Float = 0.1 + innerProg * 0.9
            group.scale = SCNVector3(s, s, s)
            group.opacity = CGFloat(0.6 + innerProg * 0.4)
            let openAngle: Float = -20 - extraOpen * 10
            applyPetalSway(group, closedAngle: -5, openAngle: openAngle, progress: innerProg, dancePhase: dancePhase, danceAmount: danceAmount)
        }

        // Stamen
        if let group = flowerRoot.childNode(withName: "stamenGroup", recursively: false) {
            let s: Float = 0.1 + stamenProg * 0.9
            group.scale = SCNVector3(s, s, s)
            group.opacity = CGFloat(0.6 + stamenProg * 0.4)
            let emergeFactor = min(max((p - 0.7) / 0.3, 0), 1)
            let openAngle: Float = -20 - extraOpen * 8
            applyStamenDance(group, closedAngle: -5, openAngle: openAngle, progress: stamenProg, emergeFactor: emergeFactor, dancePhase: dancePhase, danceAmount: danceAmount)
        }

        // Center pulse
        if let center = flowerRoot.childNode(withName: "centerNode", recursively: false) {
            let cs: Float = 0.2 + centerProg * 0.8
            let centerPulse: Float = 1.0 + sin(dancePhase * 0.5) * 0.015
            center.scale = SCNVector3(cs * centerPulse, cs * 0.5 * centerPulse, cs * centerPulse)
            center.opacity = CGFloat(0.5 + centerProg * 0.5)
        }

        // Bloom glow pulsing
        if let glow = flowerRoot.childNode(withName: "bloomGlow", recursively: false) {
            let baseIntensity = CGFloat(p) * 600
            let pulse = CGFloat(sin(dancePhase * 0.8)) * 100 * CGFloat(danceAmount)
            glow.light?.intensity = baseIntensity + pulse
            glow.light?.attenuationEndDistance = CGFloat(3.0 + danceAmount * 1.5)
            let colorShift = sin(dancePhase * 0.3) * 0.05
            glow.light?.color = UIColor(
                red: 1.0,
                green: CGFloat(0.85 + colorShift),
                blue: CGFloat(0.45 - colorShift),
                alpha: 1.0
            )
        }

        // Sparkle animation (visible in last 25% of bloom)
        if let sparkleGroup = flowerRoot.childNode(withName: "sparkleGroup", recursively: false) {
            for child in sparkleGroup.childNodes {
                guard let name = child.name, name.hasPrefix("sparkle_") else { continue }
                let parts = name.split(separator: "_")
                guard parts.count >= 4,
                      let idx = Int(parts[1]),
                      let baseTheta = Float(parts[2]),
                      let baseR = Float(parts[3]) else { continue }

                let dp = dancePhase
                let da = danceAmount

                let twinkle = sin(dp * 1.5 + Float(idx) * 2.399963)
                let visible = da > 0 && twinkle > 0
                child.opacity = visible ? CGFloat(da * 0.9) : 0

                let radialDrift = sin(dp * 0.7 + Float(idx) * 1.3) * 0.06
                let yDrift = sin(dp * 0.5 + Float(idx) * 0.9) * 0.05
                let r = baseR + radialDrift
                child.position = SCNVector3(
                    r * cos(baseTheta),
                    yDrift,
                    r * sin(baseTheta)
                )

                let scaleTwinkle: Float = 0.8 + sin(dp * 2.0 + Float(idx)) * 0.4
                child.scale = SCNVector3(scaleTwinkle, scaleTwinkle, scaleTwinkle)
            }
        }
    }

    private static func layerProgress(_ holdProgress: Float, activationStart: Float, fullAt: Float) -> Float {
        guard holdProgress > activationStart else { return 0 }
        let range = fullAt - activationStart
        guard range > 0 else { return 1 }
        return min((holdProgress - activationStart) / range, 1.0)
    }

    private static func applyPetalSway(_ group: SCNNode, closedAngle: Float, openAngle: Float, progress: Float, dancePhase: Float, danceAmount: Float) {
        let closedRad = closedAngle * Float.pi / 180
        let openRad = openAngle * Float.pi / 180
        let currentTilt = closedRad + (openRad - closedRad) * progress
        let dp = dancePhase

        for (i, wrapper) in group.childNodes.enumerated() {
            // Recover base Y angle from wrapper name
            var baseY: Float = 0
            if let name = wrapper.name, name.hasPrefix("pw_"),
               let val = Float(name.dropFirst(3)) {
                baseY = val
            }

            // Y-axis sway (3-frequency sine)
            let seed = Float(i) * 2.4
            let w1 = sin(dp * 0.8 + seed) * 2.0
            let w2 = sin(dp * 1.3 + seed * 0.4) * 1.2
            let w3 = sin(dp * 0.5 + seed * 1.7) * 0.6
            let swayDegrees = (w1 + w2 + w3) * (1.0 + danceAmount * 2.0)
            let swayRad = swayDegrees * Float.pi / 180
            wrapper.eulerAngles.y = baseY + swayRad

            if let petalNode = wrapper.childNodes.first {
                petalNode.eulerAngles.x = currentTilt

                // Radial pulse (+-2% scale)
                let radPulse = sin(dp * 0.6 + seed * 0.7) * 0.02
                let s: Float = 1.0 + radPulse
                petalNode.scale = SCNVector3(s, s, s)
            }
        }
    }

    private static func applyStamenDance(_ group: SCNNode, closedAngle: Float, openAngle: Float, progress: Float, emergeFactor: Float, dancePhase: Float, danceAmount: Float) {
        let closedRad = closedAngle * Float.pi / 180
        let openRad = openAngle * Float.pi / 180
        let currentTilt = closedRad + (openRad - closedRad) * progress
        let dp = dancePhase

        for (i, wrapper) in group.childNodes.enumerated() {
            // Recover base Y angle from wrapper name
            var baseY: Float = 0
            if let name = wrapper.name, name.hasPrefix("sw_"),
               let val = Float(name.dropFirst(3)) {
                baseY = val
            }

            // Y sway (2-frequency, different seeds than petals)
            let seed = Float(i) * 3.1
            let w1 = sin(dp * 0.9 + seed) * 2.5
            let w2 = sin(dp * 1.4 + seed * 0.6) * 1.5
            let swayDegrees = (w1 + w2) * (1.0 + danceAmount * 2.0)
            let swayRad = swayDegrees * Float.pi / 180
            wrapper.eulerAngles.y = baseY + swayRad

            if let stamenUnit = wrapper.childNodes.first {
                let extraTilt = -8.0 * Float.pi / 180 * emergeFactor
                let tiltOscillation = sin(dp * 1.1 + seed) * 3.0 * Float.pi / 180 * danceAmount
                stamenUnit.eulerAngles.x = currentTilt + extraTilt + tiltOscillation

                let s: Float = 1.0 + emergeFactor * 0.15
                stamenUnit.scale = SCNVector3(s, s, s)
            }
        }
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
        geometry: FlowerGeometry,
        useToonShader: Bool
    ) {
        let outerParams = outerDesign.meshParams
        let innerParams = innerDesign.meshParams

        // Back outer petals (tilted further out)
        let backOuterGroup = SCNNode()
        backOuterGroup.name = "backOuterGroup"
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
                    scale: 1.0,
                    useToonShader: useToonShader
                )
                backOuterGroup.addChildNode(petal)
            }
        }
        parent.addChildNode(backOuterGroup)

        // Front outer petals
        let frontOuterGroup = SCNNode()
        frontOuterGroup.name = "frontOuterGroup"
        if geometry.outerCount > 0 {
            for i in 0..<geometry.outerCount {
                let angle = Float(i) / Float(geometry.outerCount) * 2 * Float.pi
                let petal = makePetalNode(
                    params: outerParams,
                    color: outerColor,
                    width: Float(geometry.petalWidth),
                    tiltAngle: -35 * Float.pi / 180,
                    yRotation: angle,
                    scale: 1.0,
                    useToonShader: useToonShader
                )
                frontOuterGroup.addChildNode(petal)
            }
        }
        parent.addChildNode(frontOuterGroup)

        // Inner petals (smaller, less tilted, offset 30 deg from outer)
        let innerGroup = SCNNode()
        innerGroup.name = "innerGroup"
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
                    scale: 0.7,
                    useToonShader: useToonShader
                )
                innerGroup.addChildNode(petal)
            }
        }
        parent.addChildNode(innerGroup)
    }

    private static func makePetalNode(
        params: PetalMeshParams,
        color: Color,
        width: Float,
        tiltAngle: Float,
        yRotation: Float,
        scale: Float,
        useToonShader: Bool
    ) -> SCNNode {
        let petalGeometry = buildPetalGeometry(params: params, width: width, scale: scale)
        petalGeometry.materials = [petalMaterial(color: color, toon: useToonShader)]

        let petalNode = SCNNode(geometry: petalGeometry)
        petalNode.eulerAngles.x = tiltAngle

        let wrapper = SCNNode()
        wrapper.name = "pw_\(yRotation)"
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

    private static func petalMaterial(color: Color, toon: Bool) -> SCNMaterial {
        toon ? toonMaterial(color: color) : clayMaterial(color: color)
    }

    private static func clayMaterial(color: Color) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(color)
        material.roughness.contents = 0.85
        material.metalness.contents = 0.0
        material.isDoubleSided = true
        return material
    }

    private static func toonMaterial(color: Color) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .lambert
        material.diffuse.contents = UIColor(color)
        material.isDoubleSided = true
        material.shaderModifiers = [.fragment: toonFragmentShader]
        return material
    }

    /// Cel-shaded fragment modifier: quantizes the lit color into 4 distinct
    /// brightness bands while preserving hue. Runs after standard Lambert
    /// lighting so it cleanly captures ambient + directional + bloom-glow
    /// contributions, then snaps the result into stepped tones.
    private static let toonFragmentShader: String = """
    #pragma transparent
    #pragma body
    {
        vec3 c = _output.color.rgb;
        float v = max(c.r, max(c.g, c.b));
        float band;
        if (v > 0.78) {
            band = 1.0;
        } else if (v > 0.52) {
            band = 0.72;
        } else if (v > 0.27) {
            band = 0.44;
        } else {
            band = 0.24;
        }
        vec3 hue = c / max(v, 0.0001);
        _output.color.rgb = clamp(hue * band, 0.0, 1.0);
    }
    """

    // MARK: - Stamen

    private static func addStamen(
        to parent: SCNNode,
        design: StamenDesign,
        color: Color,
        geometry: FlowerGeometry,
        useToonShader: Bool
    ) {
        let stamenGroup = SCNNode()
        stamenGroup.name = "stamenGroup"

        let config = design.stamenConfig
        let baseRadius = Float(geometry.stamenScale) * 1.5 * config.lengthMultiplier
        let material = petalMaterial(color: color, toon: useToonShader)

        for i in 0..<config.count {
            // Per-filament deterministic variation (stable across rebuilds)
            let angleJitter = (hashRand(i, 1) - 0.5) * 2 * config.angularJitter
            let lengthFactor = 1.0 + (hashRand(i, 2) - 0.5) * 2 * config.lengthVariance
            let leanX = (hashRand(i, 3) - 0.5) * 2 * config.leanVariance
            let leanZ = (hashRand(i, 4) - 0.5) * 2 * config.leanVariance

            let angle = Float(i) / Float(config.count) * 2 * Float.pi + angleJitter
            let perRadius = baseRadius * lengthFactor

            // Filament
            let filament = SCNCylinder(radius: CGFloat(config.filamentRadius), height: CGFloat(perRadius))
            filament.radialSegmentCount = 6
            filament.materials = [material]

            let filamentNode = SCNNode(geometry: filament)
            filamentNode.position = SCNVector3(0, perRadius / 2, 0)

            // Anther tip
            let anther = SCNSphere(radius: CGFloat(config.tipRadius))
            anther.segmentCount = 8
            anther.materials = [material]

            let antherNode = SCNNode(geometry: anther)
            antherNode.position = SCNVector3(0, perRadius, 0)

            // Lean group — organic per-filament tilt that survives bloom dance
            let leanGroup = SCNNode()
            if config.leanVariance > 0 {
                leanGroup.eulerAngles = SCNVector3(leanX, 0, leanZ)
            }
            leanGroup.addChildNode(filamentNode)
            leanGroup.addChildNode(antherNode)

            let stamenUnit = SCNNode()
            stamenUnit.addChildNode(leanGroup)
            stamenUnit.eulerAngles.x = -20 * Float.pi / 180

            let wrapper = SCNNode()
            wrapper.name = "sw_\(angle)"
            wrapper.eulerAngles.y = angle
            wrapper.addChildNode(stamenUnit)
            stamenGroup.addChildNode(wrapper)
        }

        parent.addChildNode(stamenGroup)
    }

    /// Deterministic pseudo-random in 0..1 — stable per (index, seed).
    /// Used so per-filament variation stays constant across rebuilds.
    private static func hashRand(_ i: Int, _ seed: Int) -> Float {
        let v = Float(i) * 12.9898 + Float(seed) * 78.233
        let s = sin(v) * 43758.5453
        return s - floor(s)
    }

    // MARK: - Center

    private static func addCenter(
        to parent: SCNNode,
        design: CenterDesign,
        color: Color,
        geometry: FlowerGeometry,
        useToonShader: Bool
    ) {
        let radius = Float(geometry.centerScale) * 0.6
        let sphere = SCNSphere(radius: CGFloat(radius))
        sphere.segmentCount = 24
        sphere.materials = [petalMaterial(color: color, toon: useToonShader)]

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
    let lengthMultiplier: Float   // 1.0 = normal; >1 reaches further out of the flower
    let lengthVariance: Float     // 0 = uniform; 0.2 = +-20% per filament
    let leanVariance: Float       // radians of random tilt per filament (organic look)
    let angularJitter: Float      // radians of random Y rotation jitter (uneven spacing)
}

extension StamenDesign {
    fileprivate var stamenConfig: StamenConfig {
        switch self {
        case .dewdrops:    StamenConfig(count: 8,  filamentRadius: 0.012, tipRadius: 0.035, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
        case .fairyDust:   StamenConfig(count: 12, filamentRadius: 0.006, tipRadius: 0.026, lengthMultiplier: 2.2, lengthVariance: 0.22, leanVariance: 0.22, angularJitter: 0.18)
        case .sunburst:    StamenConfig(count: 16, filamentRadius: 0.012, tipRadius: 0.025, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
        case .tendrils:    StamenConfig(count: 6,  filamentRadius: 0.016, tipRadius: 0.022, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
        case .pollenCloud: StamenConfig(count: 10, filamentRadius: 0.010, tipRadius: 0.040, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
        case .crown:       StamenConfig(count: 8,  filamentRadius: 0.018, tipRadius: 0.035, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
        case .corona:      StamenConfig(count: 5,  filamentRadius: 0.015, tipRadius: 0.042, lengthMultiplier: 1.0, lengthVariance: 0,    leanVariance: 0,    angularJitter: 0)
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
