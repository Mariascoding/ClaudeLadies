import SwiftUI
import SceneKit

struct Flower3DView: View {
    let outerDesign: OuterPetalDesign
    let innerDesign: InnerPetalDesign
    let stamenDesign: StamenDesign
    let centerDesign: CenterDesign
    let outerColor: Color
    let innerColor: Color
    let stamenColor: Color
    let centerColor: Color
    let geometry: FlowerGeometry
    var isBloomMode: Bool = false
    var bloomProgress: CGFloat = 0

    @State private var scene: SCNScene?

    var body: some View {
        Group {
            if let scene {
                SceneView(
                    scene: scene,
                    options: isBloomMode ? [] : [.allowsCameraControl]
                )
            } else {
                Color.clear
            }
        }
        .onAppear { rebuildScene() }
        .onChange(of: outerDesign) { rebuildScene() }
        .onChange(of: innerDesign) { rebuildScene() }
        .onChange(of: stamenDesign) { rebuildScene() }
        .onChange(of: centerDesign) { rebuildScene() }
        .onChange(of: outerColor.description) { rebuildScene() }
        .onChange(of: innerColor.description) { rebuildScene() }
        .onChange(of: stamenColor.description) { rebuildScene() }
        .onChange(of: centerColor.description) { rebuildScene() }
        .onChange(of: geometry) { rebuildScene() }
        .onChange(of: isBloomMode) {
            if isBloomMode, let scene {
                Flower3DSceneBuilder.applyBloom(to: scene, progress: bloomProgress)
            }
        }
        .onChange(of: bloomProgress) {
            if isBloomMode, let scene {
                Flower3DSceneBuilder.applyBloom(to: scene, progress: bloomProgress)
            }
        }
    }

    private func rebuildScene() {
        scene = Flower3DSceneBuilder.buildScene(
            outerDesign: outerDesign,
            innerDesign: innerDesign,
            stamenDesign: stamenDesign,
            centerDesign: centerDesign,
            outerColor: outerColor,
            innerColor: innerColor,
            stamenColor: stamenColor,
            centerColor: centerColor,
            geometry: geometry
        )
        if isBloomMode, let scene {
            Flower3DSceneBuilder.applyBloom(to: scene, progress: bloomProgress)
        }
    }
}
