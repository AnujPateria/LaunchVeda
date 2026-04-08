import SwiftUI
import SceneKit
import Combine

struct InteractiveLaunchView: View {
    @Environment(\.dismiss) private var dismiss
    
    // ui state
    @State private var time: TimeInterval = 0.0
    @State private var state: TrajectoryState = TrajectoryState(altitude: 0, velocity: 0, position: SCNVector3Zero, rotation: SCNVector4Zero, tiltAngle: 0)
    @State private var currentStage: Int = 1
    @State private var selectedPartName: String? = nil
    @State private var cameraMode: UIManager.CameraMode = .side
    @State private var isSoundEnabled: Bool = true
    
    // core engine
    @StateObject private var engine = LaunchSimulationEngine()
    
    var body: some View {
        ZStack {
            // dynamic sky background
            dynamicSkyBackground(altitude: state.altitude)
            
            // 3d scenekit layer
            LaunchSceneView(
                engine: engine,
                selectedPartName: $selectedPartName,
                cameraMode: $cameraMode
            )
            .ignoresSafeArea()
            
            // ui overlay
            UIManager(
                state: state,
                currentStage: currentStage,
                time: time,
                selectedPartName: $selectedPartName,
                cameraMode: $cameraMode,
                isSoundEnabled: $isSoundEnabled
            )
            .padding(.top, 40) // safe area adjustment
            
            // back button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(engine.$trajectoryState) { s in self.state = s }
        .onReceive(engine.$currentStage) { stage in self.currentStage = stage }
        .onReceive(engine.$time) { t in self.time = t }
        .onAppear {
            engine.start()
        }
        .onDisappear {
            engine.stop()
        }
    }
    
    @ViewBuilder
    private func dynamicSkyBackground(altitude: Double) -> some View {
        // linearly interpolate background from light blue (sea level) to black (space)
        let maxAtmos: Double = 50.0 // km
        let progress = min(altitude / maxAtmos, 1.0)
        
        let r = 0.5 * (1.0 - progress) // 0.5 -> 0
        let g = 0.7 * (1.0 - progress) // 0.7 -> 0
        let b = 1.0 * (1.0 - progress) + 0.08 * progress // 1.0 -> 0.08
        
        Color(red: r, green: g, blue: b)
            .ignoresSafeArea()
            .animation(.linear(duration: 0.1), value: progress)
    }
}

// simulation engine binding

class LaunchSimulationEngine: ObservableObject {
    @Published var trajectoryState: TrajectoryState = TrajectoryState(altitude: 0, velocity: 0, position: SCNVector3Zero, rotation: SCNVector4Zero, tiltAngle: 0)
    @Published var currentStage: Int = 1
    @Published var time: TimeInterval = 0.0
    
    let scene = SCNScene()
    let rocketController = RocketController(rocketName: "Generic")
    lazy var stageManager = StageManager(scene: scene, rocketRoot: rocketController.rootNode)
    let trajectorySystem = TrajectorySystem()
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    
    init() {
        setupScene()
    }
    
    private func setupScene() {
        scene.rootNode.addChildNode(rocketController.rootNode)
        
        // lighting
        let ambientLight = SCNNode()
        ambientLight.light = { let l = SCNLight(); l.type = .ambient; l.intensity = 100; l.color = UIColor(white: 0.6, alpha: 1); return l }()
        scene.rootNode.addChildNode(ambientLight)
        
        let sunLight = SCNNode()
        sunLight.light = { let l = SCNLight(); l.type = .directional; l.intensity = 800; l.castsShadow = true; return l }()
        sunLight.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(sunLight)
    }
    
    func start() {
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick(link: CADisplayLink) {
        let elapsed = CACurrentMediaTime() - startTime
        self.time = elapsed
        
        // calculate physics/math
        let newState = trajectorySystem.calculateState(at: elapsed * 4.0) // speed up time 4x for visual demo
        
        // trigger separations
        let newStage = stageManager.checkTriggers(altitude: newState.altitude, velocity: newState.velocity)
        
        // update 3d rocket parts and particles
        rocketController.updateState(state: newState, currentStage: newStage)
        
        // publish state to ui
        self.trajectoryState = newState
        self.currentStage = newStage
    }
}

// scenekit view wrapper

struct LaunchSceneView: UIViewRepresentable {
    @ObservedObject var engine: LaunchSimulationEngine
    @Binding var selectedPartName: String?
    @Binding var cameraMode: UIManager.CameraMode
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = engine.scene
        scnView.backgroundColor = .clear // let swiftui handle gradient background
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.showsStatistics = false
        
        // add gesture recognizer
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tap)
        
        // initialize cameras
        context.coordinator.setupCameras(in: engine.scene)
        
        return scnView
    }
    
    func updateUIView(_ scnView: SCNView, context: Context) {
        // update camera targeting based on state
        context.coordinator.updateCameraPosition(
            rocketNode: engine.rocketController.rootNode,
            mode: cameraMode,
            view: scnView
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedPartName: $selectedPartName)
    }
    
    @MainActor
    class Coordinator: NSObject {
        var selectedPartName: Binding<String?>
        let interactionHandler: InteractionHandler
        
        var sideCameraNode: SCNNode!
        var followCameraNode: SCNNode!
        
        init(selectedPartName: Binding<String?>) {
            self.selectedPartName = selectedPartName
            self.interactionHandler = InteractionHandler(selectedNodeName: selectedPartName)
        }
        
        @objc func handleTap(_ gesture: UIGestureRecognizer) {
            guard let view = gesture.view as? SCNView else { return }
            let location = gesture.location(in: view)
            interactionHandler.handleTap(at: location, in: view)
        }
        
        func setupCameras(in scene: SCNScene) {
            // side camera (fixed view of overall trajectory)
            sideCameraNode = SCNNode()
            let cam1 = SCNCamera()
            cam1.zNear = 1
            cam1.zFar = 500
            cam1.fieldOfView = 60
            sideCameraNode.camera = cam1
            sideCameraNode.position = SCNVector3(x: 15, y: 15, z: 80)
            sideCameraNode.look(at: SCNVector3(x: 0, y: 30, z: -10))
            scene.rootNode.addChildNode(sideCameraNode)
            
            // follow camera (attached to scene, but constraints to rocket later)
            followCameraNode = SCNNode()
            let cam2 = SCNCamera()
            cam2.zNear = 0.5
            cam2.zFar = 500
            cam2.fieldOfView = 50
            followCameraNode.camera = cam2
            scene.rootNode.addChildNode(followCameraNode)
        }
        
        func updateCameraPosition(rocketNode: SCNNode, mode: UIManager.CameraMode, view: SCNView) {
            switch mode {
            case .side:
                view.pointOfView = sideCameraNode
            case .follow:
                view.pointOfView = followCameraNode
                // follow behind logic
                // calculate position relative to rocket's orientation
                let rocketPos = rocketNode.presentation.position
                let offset = SCNVector3(x: 10, y: 2, z: 12) // slightly right, above, and behind
                
                // let's use simple smooth follow for orientation independence visually
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                followCameraNode.position = SCNVector3(rocketPos.x + offset.x, rocketPos.y + offset.y, rocketPos.z + offset.z)
                followCameraNode.look(at: rocketPos)
                SCNTransaction.commit()
                
            case .zoom:
                view.pointOfView = followCameraNode
                let rocketPos = rocketNode.presentation.position
                let offset = SCNVector3(x: 4, y: 0, z: 8) // close up
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                followCameraNode.position = SCNVector3(rocketPos.x + offset.x, rocketPos.y + offset.y, rocketPos.z + offset.z)
                followCameraNode.look(at: rocketPos)
                SCNTransaction.commit()
            }
        }
    }
}
