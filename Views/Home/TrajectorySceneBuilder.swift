import SwiftUI
import SceneKit
#if canImport(UIKit)
import UIKit
typealias SCNColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias SCNColor = NSColor
#endif

// trajectoryscenebuilder — builds scenekit scene with earth, trajectory, and rocket
class TrajectorySceneBuilder {
    static let planetCategoryMask = 1 << 6

    let scene = SCNScene()
    weak var scnView: SCNView?
    let rocketName: String
    let trajectoryPoints: [TrajectoryPoint]
    let stageEvents: [StageEvent]

    // scale factor: 1 scenekit unit = 1 km
    let scale: Float = 0.08

    private(set) var stageNodes: [String: SCNNode] = [:]
    private var originalPositions: [String: SCNVector3] = [:]
    private(set) var rocketParent = SCNNode()
    private(set) var trajectoryNode = SCNNode()
    
    // camera tracking state
    private var previousTargetPos: SCNVector3?

    init(rocketName: String, points: [TrajectoryPoint], events: [StageEvent]) {
        self.rocketName = rocketName
        self.trajectoryPoints = points
        self.stageEvents = events
        setupScene()
    }

    private func setupScene() {
        scene.background.contents = SCNColor.black

        addStarField()
        addEarthSurface()
        addTrajectoryLine()
        addRocket()
        addLighting()
        addCamera()
    }

    // stars
    private func addStarField() {
        // dense multi-layer starfield with subtle color variation.
        for _ in 0..<1400 {
            let radius = CGFloat.random(in: 0.004...0.032)
            let star = SCNNode(geometry: SCNSphere(radius: radius))
            let material = SCNMaterial()
            let starColor = randomStarColor()
            material.diffuse.contents = starColor
            material.emission.contents = starColor.withAlphaComponent(0.95)
            material.lightingModel = .constant
            material.writesToDepthBuffer = false
            star.geometry?.materials = [material]

            let r = Float.random(in: 65...160)
            let theta = Float.random(in: 0...(Float.pi * 2))
            let phi = Float.random(in: 0...Float.pi)
            star.position = SCNVector3(
                r * sin(phi) * cos(theta),
                r * sin(phi) * sin(theta),
                r * cos(phi)
            )

            if Int.random(in: 0...100) < 8 {
                let twinkle = SCNAction.sequence([
                    .fadeOpacity(to: CGFloat.random(in: 0.35...0.65), duration: Double.random(in: 0.8...1.8)),
                    .fadeOpacity(to: CGFloat.random(in: 0.8...1.0), duration: Double.random(in: 0.8...1.8))
                ])
                star.runAction(.repeatForever(twinkle))
            }

            scene.rootNode.addChildNode(star)
        }

    }

    // earth surface + launch complex
    private func addEarthSurface() {
        // curved earth for realistic horizon.
        let earthRadius: CGFloat = 40
        let earth = SCNSphere(radius: earthRadius)
        earth.segmentCount = 120 // higher resolution
        let earthMaterial = SCNMaterial()
        earthMaterial.diffuse.contents = earthTexture()
        earthMaterial.specular.contents = SCNColor(white: 1, alpha: 0.6)
        earthMaterial.shininess = 0.5
        earthMaterial.normal.contents = earthBumpMapMap()
        earthMaterial.lightingModel = .physicallyBased
        earth.materials = [earthMaterial]

        let earthNode = SCNNode(geometry: earth)
        earthNode.name = "planet_earth"
        earthNode.categoryBitMask = Self.planetCategoryMask
        earthNode.position = SCNVector3(0, -earthRadius, 0)
        earthNode.eulerAngles = SCNVector3(0, Float.pi * 0.08, 0)
        scene.rootNode.addChildNode(earthNode)

        // realistic launch complex ground (dark concrete, no green tint).
        let launchComplex = SCNCylinder(radius: 1.35, height: 0.10)
        let groundMat = SCNMaterial()
        groundMat.diffuse.contents = SCNColor(red: 0.16, green: 0.17, blue: 0.19, alpha: 1)
        groundMat.roughness.contents = 0.82
        groundMat.metalness.contents = 0.04
        groundMat.emission.contents = SCNColor.black
        launchComplex.materials = [groundMat]
        let launchComplexNode = SCNNode(geometry: launchComplex)
        launchComplexNode.position = SCNVector3(0, 0.05, 0)
        scene.rootNode.addChildNode(launchComplexNode)

        // pad ring and flame trench detail.
        let padRing = SCNTorus(ringRadius: 0.56, pipeRadius: 0.03)
        let ringMat = SCNMaterial()
        ringMat.diffuse.contents = SCNColor(red: 0.45, green: 0.47, blue: 0.50, alpha: 1)
        ringMat.metalness.contents = 0.35
        ringMat.roughness.contents = 0.5
        padRing.materials = [ringMat]
        let ringNode = SCNNode(geometry: padRing)
        ringNode.position = SCNVector3(0, 0.095, 0)
        ringNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        scene.rootNode.addChildNode(ringNode)

        let trench = SCNBox(width: 0.85, height: 0.06, length: 0.36, chamferRadius: 0.02)
        let trenchMat = SCNMaterial()
        trenchMat.diffuse.contents = SCNColor(red: 0.10, green: 0.11, blue: 0.12, alpha: 1)
        trenchMat.roughness.contents = 0.9
        trench.materials = [trenchMat]
        let trenchNode = SCNNode(geometry: trench)
        trenchNode.position = SCNVector3(0, 0.03, -0.25)
        scene.rootNode.addChildNode(trenchNode)
    }

    private func randomStarColor() -> SCNColor {
        let choices: [SCNColor] = [
            SCNColor(white: 1, alpha: 1),
            SCNColor(red: 0.86, green: 0.91, blue: 1.0, alpha: 1),
            SCNColor(red: 1.0, green: 0.93, blue: 0.82, alpha: 1),
            SCNColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1)
        ]
        return choices.randomElement() ?? .white
    }

#if os(macOS)
    private func earthTexture() -> UIImage { return UIImage() }
    private func cloudTexture() -> UIImage { return UIImage() }
    private func nebulaTexture(colors: [SCNColor]) -> UIImage { return UIImage() }
#else
    private func earthTexture() -> UIImage {
        let size = CGSize(width: 1024, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            _ = CGRect(origin: .zero, size: size)

            let ocean = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    SCNColor(red: 0.03, green: 0.10, blue: 0.25, alpha: 1).cgColor,
                    SCNColor(red: 0.03, green: 0.22, blue: 0.44, alpha: 1).cgColor,
                    SCNColor(red: 0.02, green: 0.14, blue: 0.30, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 0.5, 1]
            )
            if let ocean {
                cg.drawLinearGradient(ocean, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            }

            let continents = SCNColor(red: 0.17, green: 0.36, blue: 0.17, alpha: 0.95)
            continents.setFill()

            UIBezierPath(ovalIn: CGRect(x: 120, y: 140, width: 250, height: 140)).fill()
            UIBezierPath(ovalIn: CGRect(x: 480, y: 110, width: 280, height: 180)).fill()
            UIBezierPath(ovalIn: CGRect(x: 770, y: 210, width: 170, height: 110)).fill()
            UIBezierPath(ovalIn: CGRect(x: 350, y: 260, width: 140, height: 85)).fill()

            SCNColor.white.withAlphaComponent(0.16).setFill()
            UIBezierPath(ovalIn: CGRect(x: 250, y: 110, width: 200, height: 70)).fill()
            UIBezierPath(ovalIn: CGRect(x: 620, y: 200, width: 260, height: 80)).fill()
        }
    }

    private func earthBumpMapMap() -> UIImage {
        let size = CGSize(width: 512, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // create a pseudo-bump map from the earth texture
            SCNColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            SCNColor.white.withAlphaComponent(0.4).setFill()
            UIBezierPath(ovalIn: CGRect(x: 60, y: 70, width: 125, height: 70)).fill()
            UIBezierPath(ovalIn: CGRect(x: 240, y: 55, width: 140, height: 90)).fill()
            UIBezierPath(ovalIn: CGRect(x: 385, y: 105, width: 85, height: 55)).fill()
            UIBezierPath(ovalIn: CGRect(x: 175, y: 130, width: 70, height: 42)).fill()
        }
    }

    private func cloudTexture() -> UIImage {
        let size = CGSize(width: 1024, height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            SCNColor.clear.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            // generate procedural-looking clouds
            for _ in 0..<150 {
                let x = CGFloat.random(in: -50...size.width+50)
                let y = CGFloat.random(in: -50...size.height+50)
                let r1 = CGFloat.random(in: 10...80)
                let r2 = CGFloat.random(in: 10...40)
                let alpha = CGFloat.random(in: 0.05...0.25)
                
                let gradCoords = [
                    SCNColor.white.withAlphaComponent(alpha * 1.5).cgColor,
                    SCNColor.white.withAlphaComponent(alpha).cgColor,
                    SCNColor.white.withAlphaComponent(0).cgColor
                ]
                let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradCoords as CFArray, locations: [0.0, 0.4, 1.0])!
                let center = CGPoint(x: x, y: y)
                
                // draw multiple overlapping radial gradients to look like puffy clouds
                ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: max(r1, r2), options: .drawsBeforeStartLocation)
            }
        }
    }
#endif

    // trajectory line (catmull-rom spline for smooth curves)
    private func addTrajectoryLine() {
        guard trajectoryPoints.count > 2 else { return }

        // generate smooth spline from raw trajectory points
        let rawPositions = trajectoryPoints.map { pt in
            SCNVector3(pt.x * scale, pt.y * scale, pt.z * scale)
        }
        let smoothPositions = catmullRomSubdivide(rawPositions, subdivisions: 4)

        // build line segments
        var lineVertices: [SCNVector3] = []
        for i in 0..<(smoothPositions.count - 1) {
            lineVertices.append(smoothPositions[i])
            lineVertices.append(smoothPositions[i + 1])
        }

        let source = SCNGeometrySource(vertices: lineVertices)
        let indices: [Int32] = Array(0..<Int32(lineVertices.count))
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let lineGeo = SCNGeometry(sources: [source], elements: [element])

        let lineMat = SCNMaterial()
        lineMat.diffuse.contents = SCNColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.5)
        lineMat.emission.contents = SCNColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 0.5)
        lineMat.lightingModel = .constant
        lineGeo.firstMaterial = lineMat

        trajectoryNode = SCNNode(geometry: lineGeo)
        scene.rootNode.addChildNode(trajectoryNode)

        // altitude markers every 50 km
        for alt in stride(from: 50, through: 300, by: 50) {
            let marker = SCNText(string: "\(alt) km", extrusionDepth: 0.01)
            marker.font = UIFont.systemFont(ofSize: 0.2, weight: .medium)
            marker.firstMaterial?.diffuse.contents = SCNColor(white: 1, alpha: 0.35)
            marker.firstMaterial?.lightingModel = .constant
            let mNode = SCNNode(geometry: marker)
            mNode.position = SCNVector3(-2 * scale, Float(alt) * scale, 0)
            mNode.constraints = [SCNBillboardConstraint()]
            scene.rootNode.addChildNode(mNode)

            let hLine = SCNBox(width: 50, height: 0.005, length: 0.005, chamferRadius: 0)
            hLine.firstMaterial?.diffuse.contents = SCNColor(white: 0.3, alpha: 0.15)
            hLine.firstMaterial?.lightingModel = .constant
            let hNode = SCNNode(geometry: hLine)
            hNode.position = SCNVector3(15 * scale, Float(alt) * scale, 0)
            scene.rootNode.addChildNode(hNode)
        }
    }

    /// catmull-rom subdivision for smooth curves
    private func catmullRomSubdivide(_ points: [SCNVector3], subdivisions: Int) -> [SCNVector3] {
        guard points.count >= 2 else { return points }
        var result: [SCNVector3] = []
        for i in 0..<(points.count - 1) {
            let p0 = points[max(0, i - 1)]
            let p1 = points[i]
            let p2 = points[min(points.count - 1, i + 1)]
            let p3 = points[min(points.count - 1, i + 2)]
            for s in 0..<subdivisions {
            let t = Float(s) / Float(subdivisions)
#if os(macOS)
                let px0 = CGFloat(p0.x), px1 = CGFloat(p1.x), px2 = CGFloat(p2.x), px3 = CGFloat(p3.x)
                let py0 = CGFloat(p0.y), py1 = CGFloat(p1.y), py2 = CGFloat(p2.y), py3 = CGFloat(p3.y)
                let pz0 = CGFloat(p0.z), pz1 = CGFloat(p1.z), pz2 = CGFloat(p2.z), pz3 = CGFloat(p3.z)
                typealias MathFloat = CGFloat
#else
                let px0 = Float(p0.x), px1 = Float(p1.x), px2 = Float(p2.x), px3 = Float(p3.x)
                let py0 = Float(p0.y), py1 = Float(p1.y), py2 = Float(p2.y), py3 = Float(p3.y)
                let pz0 = Float(p0.z), pz1 = Float(p1.z), pz2 = Float(p2.z), pz3 = Float(p3.z)
                typealias MathFloat = Float
#endif
                let c2: MathFloat = 2.0, c3: MathFloat = 3.0, c4: MathFloat = 4.0, c5: MathFloat = 5.0, c05: MathFloat = 0.5
                
                let t_fl = MathFloat(t)
                let tt_fl = t_fl * t_fl
                let ttt_fl = tt_fl * t_fl

                let xTerm1 = c2 * px1, yTerm1 = c2 * py1, zTerm1 = c2 * pz1
                let xTerm2 = (-px0 + px2) * t_fl, yTerm2 = (-py0 + py2) * t_fl, zTerm2 = (-pz0 + pz2) * t_fl
                
                let xBase3 = (c2 * px0) - (c5 * px1) + (c4 * px2) - px3
                let yBase3 = (c2 * py0) - (c5 * py1) + (c4 * py2) - py3
                let zBase3 = (c2 * pz0) - (c5 * pz1) + (c4 * pz2) - pz3
                let xTerm3 = xBase3 * tt_fl
                let yTerm3 = yBase3 * tt_fl
                let zTerm3 = zBase3 * tt_fl
                
                let xBase4 = -px0 + (c3 * px1) - (c3 * px2) + px3
                let yBase4 = -py0 + (c3 * py1) - (c3 * py2) + py3
                let zBase4 = -pz0 + (c3 * pz1) - (c3 * pz2) + pz3
                let xTerm4 = xBase4 * ttt_fl
                let yTerm4 = yBase4 * ttt_fl
                let zTerm4 = zBase4 * ttt_fl

                let x = c05 * (xTerm1 + xTerm2 + xTerm3 + xTerm4)
                let y = c05 * (yTerm1 + yTerm2 + yTerm3 + yTerm4)
                let z = c05 * (zTerm1 + zTerm2 + zTerm3 + zTerm4)
#if os(macOS)
                result.append(SCNVector3(CGFloat(x), CGFloat(y), CGFloat(z)))
#else
                result.append(SCNVector3(Float(x), Float(y), Float(z)))
#endif
            }
        }
        result.append(points.last!)
        return result
    }



    private var isSaturnV: Bool { rocketName.contains("Saturn V") }

    // rocket (built from rocketstagedata)
    private func addRocket() {
        rocketParent = SCNNode()
        rocketParent.position = SCNVector3(0, 0.2, 0) // start slightly above pad

        addGeneratedRocket()

        scene.rootNode.addChildNode(rocketParent)
    }

    private func addGeneratedRocket() {
        let stages = RocketStageData.stages(for: rocketName)
        var currentY: Float = 0
        let rocketScale: Float = 0.008

        for stage in stages {
            let stageNode = buildStageNode(stage: stage, rocketScale: rocketScale)
            stageNode.position = SCNVector3(0, currentY, 0)
            originalPositions[stage.name] = stageNode.position
            rocketParent.addChildNode(stageNode)
            stageNodes[stage.name] = stageNode
            currentY += Float(stage.height) * rocketScale
        }
    }

    private func buildStageNode(stage: RocketStageData, rocketScale: Float) -> SCNNode {
        let node = SCNNode()
        let h = Float(stage.height) * rocketScale
        let r = Float(stage.relativeWidth) * 0.15

        // main body cylinder
        let cyl = SCNCylinder(radius: CGFloat(r), height: CGFloat(h))
        let bodyMat = SCNMaterial()
        bodyMat.diffuse.contents = SCNColor(stage.bodyColor)
        bodyMat.metalness.contents = 0.7
        bodyMat.roughness.contents = 0.25
        bodyMat.lightingModel = .physicallyBased
        cyl.firstMaterial = bodyMat
        let cylNode = SCNNode(geometry: cyl)
        cylNode.name = componentNodeIdentifier(for: stage, component: .body)
        cylNode.position = SCNVector3(0, h / 2, 0)
        node.addChildNode(cylNode)

        // nosecone
        if stage.hasCone {
            let cone = SCNCone(topRadius: 0, bottomRadius: CGFloat(r), height: CGFloat(Float(stage.topCapHeight) * rocketScale))
            cone.firstMaterial = bodyMat.copy() as? SCNMaterial
            let coneNode = SCNNode(geometry: cone)
            coneNode.name = componentNodeIdentifier(for: stage, component: .cone)
            coneNode.position = SCNVector3(0, h + Float(stage.topCapHeight) * rocketScale * 0.5, 0)
            node.addChildNode(coneNode)
        }

        // engine bells
        if stage.hasEngines {
            let bellH: Float = Float(stage.bottomCapHeight) * rocketScale * 0.8
            let bellMat = SCNMaterial()
            bellMat.diffuse.contents = SCNColor(red: 0.85, green: 0.68, blue: 0.22, alpha: 1)
            bellMat.metalness.contents = 0.85
            bellMat.roughness.contents = 0.15
            bellMat.lightingModel = .physicallyBased

            let n = stage.engineCount
            if n == 1 {
                let bell = SCNCone(topRadius: CGFloat(r * 0.1), bottomRadius: CGFloat(r * 0.35), height: CGFloat(bellH))
                bell.firstMaterial = bellMat
                let bellNode = SCNNode(geometry: bell)
                bellNode.name = componentNodeIdentifier(for: stage, component: .engine)
                bellNode.position = SCNVector3(0, -bellH / 2, 0)
                node.addChildNode(bellNode)
                
                // add plume
                addEnginePlume(to: bellNode, scale: rocketScale)
            } else {
                let bellRadius: Float = r * 0.25
                let ringR: Float = r * 0.55
                for i in 0..<n {
                    let angle = Float(i) / Float(n) * Float.pi * 2
                    let bell = SCNCone(topRadius: CGFloat(bellRadius * 0.15), bottomRadius: CGFloat(bellRadius), height: CGFloat(bellH))
                    bell.firstMaterial = bellMat
                    let bellNode = SCNNode(geometry: bell)
                    bellNode.name = componentNodeIdentifier(for: stage, component: .engine)
                    bellNode.position = SCNVector3(ringR * cos(angle), -bellH / 2, ringR * sin(angle))
                    
                    // add plume
                    addEnginePlume(to: bellNode, scale: rocketScale)
                    
                    node.addChildNode(bellNode)
                }
            }
        }

        // color bands
        for band in stage.bands {
            let bandH = Float(band.height * stage.height) * rocketScale
            let bandY = Float(band.y * stage.height) * rocketScale
            let bandGeo = SCNCylinder(radius: CGFloat(r + 0.002), height: CGFloat(bandH))
            let bandMat = SCNMaterial()
            bandMat.diffuse.contents = SCNColor(band.color)
            bandMat.lightingModel = .physicallyBased
            bandGeo.firstMaterial = bandMat
            let bandNode = SCNNode(geometry: bandGeo)
            bandNode.name = componentNodeIdentifier(for: stage, component: .band)
            bandNode.position = SCNVector3(0, bandY + bandH / 2, 0)
            node.addChildNode(bandNode)
        }

        node.name = stage.name
        return node
    }

    private enum StageComponent {
        case body
        case cone
        case engine
        case band
    }

    private func componentNodeIdentifier(for stage: RocketStageData, component: StageComponent) -> String {
        let stageName = stage.name.lowercased()

        if rocketName.contains("Saturn") {
            if stageName.contains("s-ic") {
                return component == .engine ? "sic_f1" : "sic"
            }
            if stageName.contains("s-ii") {
                return component == .engine ? "sii_engines" : "sii"
            }
            if stageName.contains("s-ivb") {
                return component == .engine ? "sivb_j2" : "sivb"
            }
            if stageName.contains("apollo") {
                if component == .cone { return "les" }
                if component == .engine { return "sm_sps" }
                return "cm"
            }
        }

        if rocketName.contains("Falcon") {
            if stageName.contains("first stage") {
                return component == .engine ? "merlin9" : "s1"
            }
            if stageName.contains("second stage") {
                return component == .engine ? "mvac" : "s2"
            }
            if stageName.contains("fairing") {
                return "fairing"
            }
        }

        if rocketName.contains("LVM") {
            if stageName.contains("s200") {
                return component == .engine ? "s200_nozzle" : "lvm3_s200"
            }
            if stageName.contains("l110") {
                return component == .engine ? "lvm3_vikas" : "lvm3_l110"
            }
            if stageName.contains("c25") {
                return component == .engine ? "lvm3_ce20" : "lvm3_c25"
            }
            if stageName.contains("fairing") {
                return "lvm3_ogive"
            }
        }

        if rocketName.contains("PSLV") {
            if stageName.contains("ps1") {
                if component == .engine { return "pslv_core" }
                if component == .band { return "pslv_strap" }
                return "pslv_ps1"
            }
            if stageName.contains("ps2") {
                return component == .engine ? "pslv_vikas" : "pslv_ps2"
            }
            if stageName.contains("ps3 + ps4") {
                if component == .engine { return "ps4_l25" }
                if component == .band { return "pslv_ps4" }
                return "pslv_ps3"
            }
            if stageName.contains("fairing") {
                return "pslv_fairing"
            }
        }

        if rocketName.contains("SLS") {
            if stageName.contains("core stage") {
                if component == .engine { return "sls_rs25" }
                if component == .band { return "sls_srb" }
                return "sls_core"
            }
            if stageName.contains("icps") {
                return component == .engine ? "sls_rl10" : "sls_icps"
            }
            if stageName.contains("orion") {
                return component == .cone ? "sls_les" : "sls_orion"
            }
        }

        if rocketName.contains("Ariane") {
            if stageName.contains("epc") {
                if component == .engine { return "ar5_vulcain" }
                if component == .band { return "ar5_eap" }
                return "ar5_epc"
            }
            if stageName.contains("esc") {
                return component == .engine ? "ar5_hm7b" : "ar5_esc"
            }
            if stageName.contains("fairing") {
                return "ar5_fairing"
            }
        }

        if rocketName.contains("H-II") {
            if stageName.contains("first stage") {
                if component == .engine { return "h2a_le7a" }
                if component == .band { return "h2a_srb" }
                return "h2a_first"
            }
            if stageName.contains("second stage") {
                return component == .engine ? "h2a_le5b" : "h2a_second"
            }
            if stageName.contains("fairing") {
                return "h2a_fairing"
            }
        }

        if rocketName.contains("Atlas") {
            if stageName.contains("ccb") {
                if component == .engine { return "atlas_rd180" }
                if component == .band { return "atlas_srb" }
                return "atlas_ccb"
            }
            if stageName.contains("centaur") {
                return component == .engine ? "atlas_rl10" : "atlas_centaur"
            }
            if stageName.contains("fairing") {
                return "atlas_fairing"
            }
        }

        if stageName.contains("fairing") {
            return "fairing"
        }
        if component == .engine {
            return "engine"
        }
        return stage.name
    }
    
    // particles
    private func addEnginePlume(to engineNode: SCNNode, scale: Float) {
        // high-realism engine exhaust particle system
        let fire = SCNParticleSystem()
        fire.particleColor = SCNColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        fire.particleColorVariation = SCNVector4(0.1, 0.2, 0.0, 0.0)
        fire.particleSize = CGFloat(scale * 1.5)
        fire.particleSizeVariation = CGFloat(scale * 0.3)
        fire.particleVelocity = CGFloat(scale * 80.0)
        fire.particleVelocityVariation = CGFloat(scale * 10.0)
        fire.emissionDuration = 1.0
        fire.loops = true
        fire.birthRate = 0 // initially off
        fire.particleLifeSpan = 0.2
        fire.particleLifeSpanVariation = 0.05
        fire.spreadingAngle = 2.5
        fire.emitterShape = SCNSphere(radius: CGFloat(scale * 0.5))
        fire.blendMode = .additive
        
        // custom texture for fire using coregraphics
        let particleImage = createParticleImage(color: SCNColor.white)
        fire.particleImage = particleImage
        
        
        let flameNode = SCNNode()
        flameNode.name = "exhaust_fire"
        flameNode.position = SCNVector3(0, -Float(engineNode.boundingBox.max.y - engineNode.boundingBox.min.y), 0)
        flameNode.eulerAngles = SCNVector3(Float.pi, 0, 0) // point downwards
        flameNode.addParticleSystem(fire)
        
        engineNode.addChildNode(flameNode)
    }
    
    // generates a soft, glowing spherical gradient for use as a particle texture
    private func createParticleImage(color: SCNColor) -> UIImage {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let center = CGPoint(x: 16, y: 16)
            let colors = [color.cgColor, color.withAlphaComponent(0).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0]) {
                ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: 16, options: [])
            }
        }
    }
    
    // lighting
    private func addLighting() {
        // dramatic key light (sun)
        let sun = SCNLight()
        sun.type = .directional
        sun.color = SCNColor(red: 1.0, green: 0.98, blue: 0.94, alpha: 1.0)
        sun.intensity = 2400 // strong realistic sunlight
        sun.castsShadow = true
        sun.shadowMode = .deferred
        sun.shadowSampleCount = 16 // soft shadows
        sun.shadowRadius = 8.0     // blurry soft shadows
        sun.shadowBias = 0.01
        sun.shadowMapSize = CGSize(width: 4096, height: 4096)
        let sunNode = SCNNode()
        sunNode.light = sun
        sunNode.name = "sun_directional"
        sunNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4.5, 0)
        scene.rootNode.addChildNode(sunNode)

        // realistic ambient sky fill
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = SCNColor(red: 0.45, green: 0.65, blue: 1.0, alpha: 1) // sky blue bounce
        ambient.intensity = 200 // high ambient near earth
        let ambNode = SCNNode()
        ambNode.light = ambient
        ambNode.name = "ambient_fill"
        scene.rootNode.addChildNode(ambNode)
    }

    // camera
    private func addCamera() {
        let camera = SCNCamera()
        camera.fieldOfView = 40
        camera.zNear = 0.01
        camera.zFar = 500
        
        // match initial camera setup to the dynamic follow logic
        let (minVec, maxVec) = rocketParent.boundingBox
        let rocketHeight = maxVec.y - minVec.y
        let centerOffset = rocketHeight / 2.0
        let pullBackZ = max(4.0, Double(rocketHeight) * 1.5)
        
        let camNode = SCNNode()
        camNode.camera = camera
        camNode.position = SCNVector3(x: 0, y: Float(CGFloat(centerOffset)), z: Float(CGFloat(pullBackZ)))
        camNode.look(at: SCNVector3(x: 0, y: Float(CGFloat(centerOffset)), z: 0))
        camNode.name = "mainCamera"
        scene.rootNode.addChildNode(camNode)
    }

    // catmull-rom interpolation for smooth position
    private func interpolatedPoint(at time: Double) -> (x: Float, y: Float, z: Float, velocity: Double) {
        guard trajectoryPoints.count > 1 else {
            let p = trajectoryPoints.first!
            return (p.x, p.y, p.z, p.velocity)
        }

        let t = max(trajectoryPoints.first!.time, min(time, trajectoryPoints.last!.time))

        // find bracketing index
        var idx = 0
        for i in 0..<(trajectoryPoints.count - 1) {
            if trajectoryPoints[i].time <= t && trajectoryPoints[i+1].time >= t {
                idx = i
                break
            }
        }

        let i0 = max(0, idx - 1)
        let i1 = idx
        let i2 = min(trajectoryPoints.count - 1, idx + 1)
        let i3 = min(trajectoryPoints.count - 1, idx + 2)

        let p0 = trajectoryPoints[i0]
        let p1 = trajectoryPoints[i1]
        let p2 = trajectoryPoints[i2]
        let p3 = trajectoryPoints[i3]

        let dt = p2.time - p1.time
        let frac = dt > 0 ? Float((t - p1.time) / dt) : 0
        let fracD = dt > 0 ? (t - p1.time) / dt : 0
        let tt = frac * frac
        let ttt = tt * frac

        // catmull-rom for x, y, z
        func catmull(_ v0: Float, _ v1: Float, _ v2: Float, _ v3: Float) -> Float {
            0.5 * ((2 * v1) + (-v0 + v2) * frac + (2 * v0 - 5 * v1 + 4 * v2 - v3) * tt + (-v0 + 3 * v1 - 3 * v2 + v3) * ttt)
        }

        return (
            x: catmull(p0.x, p1.x, p2.x, p3.x),
            y: catmull(p0.y, p1.y, p2.y, p3.y),
            z: catmull(p0.z, p1.z, p2.z, p3.z),
            velocity: p1.velocity + (p2.velocity - p1.velocity) * fracD
        )
    }

    /// smoothed pitch angle over a time window (prevents snapping)
    private func smoothedPitchAngle(at time: Double) -> Float {
        let window: Double = 12.0  // average over ±12 seconds
        let ahead = interpolatedPoint(at: min(time + window, trajectoryPoints.last!.time))
        let behind = interpolatedPoint(at: max(time - window, 0))
        let dx = ahead.x - behind.x
        let dy = ahead.y - behind.y
        // the trajectory is viewed from the side (+z axis looking at x/y plane).
        // rocket model natively points up (+y).
        // atan2(dy, dx) gives 0 for horizontal (+x) and pi/2 for vertical (+y).
        // so we need to rotate it by `atan2(dy, dx) - pi/2`. 
        // if it rotates 'too fast' or seems upside down, it might need to rotate in exactly atan2(dy,dx) - pi/2 but inverted if camera is looking the other way.
        // the user says "rocket rotate too fast" and shows trajectory below 50km.
        // actually, the issue in the screenshot is that the rocket is physically rotated exactly -90 deg from where it should be.
        return atan2(dy, dx) - Float.pi / 2
    }

    // position update (core loop)
    @MainActor
    func updateRocketPosition(at time: Double) {
        guard !trajectoryPoints.isEmpty else { return }

        let interp = interpolatedPoint(at: time)

        // move rocket — smooth catmull-rom position
        let targetPos = SCNVector3(interp.x * scale, interp.y * scale + 0.2, interp.z * scale)
        rocketParent.position = targetPos

        // smooth pitch using averaged tangent
#if os(macOS)
        rocketParent.eulerAngles.z = CGFloat(smoothedPitchAngle(at: time))
#else
        rocketParent.eulerAngles.z = Float(smoothedPitchAngle(at: time))
#endif

        // handle stage separations
        let separatedEvents: [StageEvent] = stageEvents.filter { event in
            return event.time <= time && (event.eventType == .separation || event.eventType == .jettison)
        }
        let separatedNames = separatedEvents.map { $0.stageName }

        for event in separatedEvents {
            if let stageNode = stageNodes[event.stageName], stageNode.parent == rocketParent {
                let worldPos = stageNode.worldPosition
                stageNode.removeFromParentNode()
                stageNode.position = worldPos
                stageNode.opacity = 0.35
                scene.rootNode.addChildNode(stageNode)

                // determine a trailing fallout path based on the rocket's pitch
                let pitch = smoothedPitchAngle(at: time)
                let dx = CGFloat(cos(pitch)) * 10 // fall backwards
                let dy = CGFloat(sin(pitch)) * 10 - 5 // fall down slightly
                
                let fallAction = SCNAction.moveBy(x: -dx,
                                                   y: dy,
                                                   z: CGFloat.random(in: -3...3),
                                                   duration: 4.0)
                fallAction.timingMode = .easeOut
                let fadeAction = SCNAction.fadeOut(duration: 4.0)
                let rotateAction = SCNAction.rotateBy(x: CGFloat.random(in: -2...2),
                                                       y: CGFloat.random(in: -1...1),
                                                       z: CGFloat.random(in: -2...2),
                                                       duration: 4.0)
                stageNode.runAction(SCNAction.group([fallAction, fadeAction, rotateAction]))
            }
        }

        for (stageName, stageNode) in stageNodes {
            if !separatedNames.contains(stageName) && stageNode.parent != rocketParent {
                stageNode.removeAllActions()
                stageNode.removeFromParentNode()
                stageNode.opacity = 1.0
                stageNode.eulerAngles = SCNVector3Zero
                if let origPos = originalPositions[stageName] {
                    stageNode.position = origPos
                }
                rocketParent.addChildNode(stageNode)
            }
        }
        
        // update particle systems
        updateParticlesAndLighting(at: time, altitude: interp.y, separatedNames: separatedNames)

        // follow camera target: keep the center of the rocket as the orbital focus
        let (minVec, maxVec) = rocketParent.boundingBox
        let rocketHeight = maxVec.y - minVec.y
        let centerOffset = rocketHeight / 2.0
        
        // add subtle camera shake during ascent
        var shakeX: Float = 0
        var shakeY: Float = 0
        
        let shouldShake = time > 0 && interp.y < 50 // shake mostly in atmosphere
        if shouldShake {
            let intensity = Float.random(in: 0.005...0.02) * (1.0 - Float(interp.y / 50))
            shakeX = Float.random(in: -intensity...intensity)
            shakeY = Float.random(in: -intensity...intensity)
        }
        
        let targetPosCenter = SCNVector3(targetPos.x + shakeX, targetPos.y + centerOffset + shakeY, targetPos.z)
        
        if let view = scnView {
            view.defaultCameraController.target = targetPosCenter
        } else {
            let pullBackZ = max(4.0, Double(rocketHeight) * 1.5)
            let chaseOffset = SCNVector3(0, 0, Float(pullBackZ))
            if let cam = scene.rootNode.childNode(withName: "mainCamera", recursively: true) {
                cam.position = SCNVector3(targetPosCenter.x + chaseOffset.x,
                                          targetPosCenter.y + chaseOffset.y,
                                          targetPosCenter.z + chaseOffset.z)
                cam.look(at: targetPosCenter)
            }
        }
        
        previousTargetPos = targetPos
    }
    
    // updates active engine effects, lighting, and ground smoke based on phase
    private func updateParticlesAndLighting(at time: Double, altitude: Float, separatedNames: [String]) {
        // rocket exhaust plumes
        for stage in stageEvents where stage.eventType == .ignition {
            let isActive = time >= stage.time
            // if the stage is discarded, turn off its engine
            let isDiscarded = separatedNames.contains(stage.stageName)
            
            let rate: CGFloat = (isActive && !isDiscarded) ? 800 : 0
            
            if let node = stageNodes[stage.stageName] {
                // find all exhaust_fire subnodes attached to engines
                node.enumerateChildNodes { (child, stop) in
                    if child.name == "exhaust_fire" {
                        child.particleSystems?.forEach { sys in
                            // expand plume width dynamically at high altitude (vacuum effect)
                            if isActive {
                                let expansion = min(1.0, altitude / 100.0) // scales 0->1 as alt reaches 100km
                                sys.spreadingAngle = CGFloat(2.5 + (expansion * 35.0))
                            }
                            sys.birthRate = rate
                        }
                    }
                }
            }
        }
        
        // dynamic lighting change (space gets darker, earth ambient reflects)
        if let ambientNode = scene.rootNode.childNode(withName: "ambient_fill", recursively: true) {
            // decrease ambient from 200 at surface to 50 in space
            let progress = min(1.0, altitude / 80.0)
            ambientNode.light?.intensity = CGFloat(200 - (progress * 150))
            
            if let directionalNode = scene.rootNode.childNode(withName: "sun_directional", recursively: true) {
                // sun gets slightly sharper and cooler in space
                directionalNode.light?.intensity = CGFloat(2400 + (progress * 800))
            }
        }
    }

    // reset
    func reset() {
        // remove separated stages and rebuild
        for (_, node) in stageNodes {
            node.removeFromParentNode()
        }
        stageNodes.removeAll()
        rocketParent.removeFromParentNode()
        rocketParent.removeFromParentNode()
        addRocket()
    }
}
