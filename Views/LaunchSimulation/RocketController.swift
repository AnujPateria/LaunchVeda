import SceneKit

class RocketController {
    let rootNode: SCNNode
    private var engineParticles: SCNParticleSystem?
    private var smokeParticles: SCNParticleSystem?
    
    init(rocketName: String) {

        self.rootNode = SCNNode()
        self.rootNode.name = "rocket_root"
        
        buildProceduralRocket()
        setupParticles()
    }
    
    private func buildProceduralRocket() {
        // stage 1
        let s1Geo = SCNCylinder(radius: 0.8, height: 6.0)
        s1Geo.firstMaterial?.diffuse.contents = UIColor.white
        s1Geo.firstMaterial?.metalness.contents = 0.2
        let s1Node = SCNNode(geometry: s1Geo)
        s1Node.name = "Stage 1"
        s1Node.position = SCNVector3(0, 3.0, 0)
        rootNode.addChildNode(s1Node)
        
        // stage 2
        let s2Geo = SCNCylinder(radius: 0.8, height: 2.5)
        s2Geo.firstMaterial?.diffuse.contents = UIColor.lightGray
        s2Geo.firstMaterial?.metalness.contents = 0.5
        let s2Node = SCNNode(geometry: s2Geo)
        s2Node.name = "Stage 2"
        s2Node.position = SCNVector3(0, 7.25, 0)
        rootNode.addChildNode(s2Node)
        
        // fairing
        let fairingGeo = SCNCone(topRadius: 0.1, bottomRadius: 0.8, height: 2.0)
        fairingGeo.firstMaterial?.diffuse.contents = UIColor.white
        let fairingNode = SCNNode(geometry: fairingGeo)
        fairingNode.name = "Fairing"
        fairingNode.position = SCNVector3(0, 9.5, 0)
        rootNode.addChildNode(fairingNode)
        
        // engine nozzle
        let engineGeo = SCNCone(topRadius: 0.7, bottomRadius: 0.3, height: 0.8)
        engineGeo.firstMaterial?.diffuse.contents = UIColor.darkGray
        let engineNode = SCNNode(geometry: engineGeo)
        engineNode.name = "Engine"
        // rotate nozzle so bottom is facing down
        engineNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
        engineNode.position = SCNVector3(0, -0.4, 0)
        s1Node.addChildNode(engineNode)
    }
    
    private func setupParticles() {
        // flame
        let flame = SCNParticleSystem()
        flame.loops = true
        flame.birthRate = 800
        flame.emissionDuration = 1
        flame.particleLifeSpan = 0.15
        flame.particleVelocity = 15
        flame.particleSize = 0.4
        flame.particleColor = UIColor.orange
        flame.emitterShape = SCNCone(topRadius: 0.5, bottomRadius: 0.1, height: 0.2)
        flame.emittingDirection = SCNVector3(0, -1, 0)
        flame.blendMode = .additive
        self.engineParticles = flame
        
        // smoke
        let smoke = SCNParticleSystem()
        smoke.loops = true
        smoke.birthRate = 200
        smoke.emissionDuration = 1
        smoke.particleLifeSpan = 2.0
        smoke.particleVelocity = 5
        smoke.particleSize = 1.2
        smoke.particleColor = UIColor.white.withAlphaComponent(0.4)
        smoke.particleColorVariation = SCNVector4(0.1, 0.1, 0.1, 0.2)
        smoke.emitterShape = SCNSphere(radius: 0.8)
        smoke.emittingDirection = SCNVector3(0, -1, 0)
        smoke.spreadingAngle = 45
        smoke.particleVelocityVariation = 2
        smoke.particleSizeVariation = 0.5
        self.smokeParticles = smoke
        
        if let s1 = rootNode.childNode(withName: "Stage 1", recursively: true) {
            s1.addParticleSystem(flame)
            s1.addParticleSystem(smoke)
        }
    }
    
    func updateState(state: TrajectoryState, currentStage: Int) {
        // apply transform
        rootNode.position = state.position
        rootNode.rotation = state.rotation
        
        // update particles based on stage and altitude
        if let flame = engineParticles, let smoke = smokeParticles {
            if currentStage == 1 {
                // full thrust
                flame.birthRate = 800
                flame.particleSize = 0.4
                // reduce smoke as altitude increases (air gets thinner)
                let smokeFactor = max(0, 1.0 - (state.altitude / 40.0))
                smoke.birthRate = CGFloat(200.0 * smokeFactor)
            } else if currentStage == 2 {
                // vacuum engine
                flame.birthRate = 400
                flame.particleSize = 0.8 // vacuum expansion
                flame.particleColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.8) // blueish mech flame
                smoke.birthRate = 0 // no smoke in space
            } else {
                // orbital / coasting
                flame.birthRate = 0
                smoke.birthRate = 0
            }
        }
    }
}
