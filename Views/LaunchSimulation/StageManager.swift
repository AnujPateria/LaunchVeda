@preconcurrency import SceneKit

class StageManager {
    let mainScene: SCNScene
    let rocketRoot: SCNNode
    
    private var hasSeparatedStage1 = false
    private var hasSeparatedFairing = false
    
    init(scene: SCNScene, rocketRoot: SCNNode) {
        self.mainScene = scene
        self.rocketRoot = rocketRoot
    }
    
    func checkTriggers(altitude: Double, velocity: Double) -> Int {
        var currentStage = 1
        
        // stage 1 separation trigger
        if altitude > 68.0 {
            currentStage = 2
            if !hasSeparatedStage1 {
                separateStage1(velocity: velocity)
                hasSeparatedStage1 = true
            }
        }
        
        // fairing separation trigger
        if altitude > 100.0 {
            if !hasSeparatedFairing {
                separateFairing(velocity: velocity)
                hasSeparatedFairing = true
            }
        }
        
        // orbital insertion (stage 3/coasting)
        if altitude > 175.0 {
            currentStage = 3
        }
        
        return currentStage
    }
    
    private func separateStage1(velocity: Double) {
        guard let s1Node = rocketRoot.childNode(withName: "Stage 1", recursively: true) else { return }
        
        // compute world position and rotation before detaching
        let worldPos = s1Node.worldPosition
        let worldRot = s1Node.worldOrientation
        
        // remove from rocket, add to scene
        s1Node.removeFromParentNode()
        mainScene.rootNode.addChildNode(s1Node)
        
        s1Node.position = worldPos
        s1Node.orientation = worldRot
        
        // stop its particles over time
        s1Node.particleSystems?.forEach { ps in
            ps.birthRate = 0
        }
        
        // add physics so it falls back down
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        physicsBody.mass = 20000 // kg
        physicsBody.friction = 0.5
        physicsBody.damping = 0.1
        // initial impulse opposite to rocket direction to simulate sep motors
        // and impart downward gravity
        // simplified fallback animation instead of full rigid-body if desired
        let fallAction = SCNAction.moveBy(x: -2, y: -50, z: -5, duration: 10.0)
        let rotateAction = SCNAction.rotateBy(x: 1, y: 0.5, z: 2, duration: 10.0)
        let fadeAction = SCNAction.fadeOpacity(to: 0, duration: 10.0)
        let group = SCNAction.group([fallAction, rotateAction, fadeAction])
        
        s1Node.runAction(.sequence([group, .removeFromParentNode()]))
        
        // move stage 2 down to visual root
        let s2Node = rocketRoot.childNode(withName: "Stage 2", recursively: true)
        let fairingNode = rocketRoot.childNode(withName: "Fairing", recursively: true)
        
        // animate stage 2 moving to origin
        let shift = SCNAction.move(by: SCNVector3(0, -7.25, 0), duration: 0.1)
        s2Node?.runAction(shift)
        fairingNode?.runAction(shift) // move fairing down with it
        
        // add vacuum particle to stage 2
        let vacuumFlame = SCNParticleSystem()
        vacuumFlame.loops = true
        vacuumFlame.birthRate = 400
        vacuumFlame.emissionDuration = 1
        vacuumFlame.particleLifeSpan = 0.2
        vacuumFlame.particleVelocity = 25
        vacuumFlame.particleSize = 0.8
        vacuumFlame.particleColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8)
        vacuumFlame.emitterShape = SCNCone(topRadius: 0.8, bottomRadius: 0.2, height: 0.5)
        vacuumFlame.emittingDirection = SCNVector3(0, -1, 0)
        vacuumFlame.blendMode = .additive
        s2Node?.addParticleSystem(vacuumFlame)
    }
    
    private func separateFairing(velocity: Double) {
        guard let fairingNode = rocketRoot.childNode(withName: "Fairing", recursively: true) else { return }
        
        // in a real simulation, we'd split the fairing into two halves.
        // for this, we'll clone it, split them left and right.
        
        let leftFairing = fairingNode.clone()
        let rightFairing = fairingNode.clone()
        
        let worldPos = fairingNode.worldPosition
        let worldRot = fairingNode.worldOrientation
        
        fairingNode.removeFromParentNode()
        
        mainScene.rootNode.addChildNode(leftFairing)
        mainScene.rootNode.addChildNode(rightFairing)
        
        leftFairing.position = worldPos
        leftFairing.orientation = worldRot
        rightFairing.position = worldPos
        rightFairing.orientation = worldRot
        
        let moveLeft = SCNAction.moveBy(x: -15, y: -10, z: 0, duration: 5.0)
        let rotateLeft = SCNAction.rotateBy(x: 0, y: 0, z: 2, duration: 5.0)
        let fade = SCNAction.fadeOpacity(to: 0, duration: 5.0)
        
        leftFairing.runAction(.sequence([.group([moveLeft, rotateLeft, fade]), .removeFromParentNode()]))
        
        let moveRight = SCNAction.moveBy(x: 15, y: -10, z: 0, duration: 5.0)
        let rotateRight = SCNAction.rotateBy(x: 0, y: 0, z: -2, duration: 5.0)
        
        rightFairing.runAction(.sequence([.group([moveRight, rotateRight, fade]), .removeFromParentNode()]))
    }
}
