import Foundation
import SceneKit

struct TrajectoryState {
    var altitude: Double       // km
    var velocity: Double       // km/h
    var position: SCNVector3   // 3d position
    var rotation: SCNVector4   // 3d rotation
    var tiltAngle: Double      // degrees from vertical
}

class TrajectorySystem {
    
    // physics simulation constants
    private let targetAltitude: Double = 200.0 // km
    private let maxVelocity: Double = 28000.0 // km/h (orbital velocity)
    private let gravityTurnStartAlt: Double = 5.0 // km
    private let gravityTurnEndAlt: Double = 50.0 // km
    private let timeToOrbit: TimeInterval = 180.0 // 3 minutes for simulation
    
    func calculateState(at time: TimeInterval) -> TrajectoryState {
        // normalize time (0.0 to 1.0)
        let phase = min(time / timeToOrbit, 1.0)
        
        // --- smooth curved trajectory using physics-based equations ---
        var alt: Double = 0.0
        var downrange: Double = 0.0
        var vel: Double = 0.0
        var pitch: Double = 0.0
        
        if phase < 0.02 {
            // phase 1: vertical lift-off (0-2% of flight)
            // pure vertical ascent with smooth acceleration
            let liftoffPhase = phase / 0.02
            alt = liftoffPhase * 8.0
            downrange = 0.0
            vel = liftoffPhase * 1200.0
            pitch = 0.0
            
        } else if phase < 0.4 {
            // phase 2: gravity turn (2-40% of flight)
            // smooth curved trajectory using trigonometric functions
            let gravityPhase = (phase - 0.02) / 0.38
            
            // smooth pitch angle using sine curve (0° to 90°)
            let pitchFactor = min(max(gravityPhase, 0), 1)
            pitch = pitchFactor * 90.0
            
            // convert pitch to radians for curve calculations
            let angle = pitch * (.pi / 2.0) / 90.0
            
            // curved trajectory using trigonometric functions
            let curveX = 1.0 - cos(angle)      // smooth horizontal gain (0 to 1)
            let curveY = sin(angle)             // smooth vertical gain (0 to 1)
            
            // apply curves to altitude and downrange
            alt = 8.0 + curveY * 180.0         // 8km to 188km
            downrange = curveX * 250.0         // 0 to 250km
            vel = 1200.0 + gravityPhase * 22000.0  // 1200 to 23200 km/h
            
        } else if phase < 0.75 {
            // phase 3: upper stage to orbit (40-75% of flight)
            // shallower arc approaching orbital altitude
            let upperPhase = (phase - 0.4) / 0.35
            
            // pitch continues to increase but more gradually
            pitch = 90.0 - (1.0 - upperPhase) * 15.0  // 90° to 75°
            
            // smooth altitude approach to orbital height
            let altCurve = sin(upperPhase * (.pi / 2.0))
            alt = 188.0 + altCurve * 60.0     // 188km to 248km
            
            // downrange continues smoothly
            let downrangeCurve = 1.0 - cos(upperPhase * (.pi / 2.0))
            downrange = 250.0 + downrangeCurve * 450.0  // 250km to 700km
            
            vel = 23200.0 + upperPhase * 4500.0  // 23200 to 27700 km/h
            
        } else {
            // phase 4: orbital insertion (75-100% of flight)
            // nearly horizontal, fine-tuning orbital parameters
            let orbitalPhase = (phase - 0.75) / 0.25
            
            // pitch becomes nearly horizontal with slight oscillation
            pitch = 75.0 + sin(orbitalPhase * (.pi / 2.0)) * 15.0  // 75° to 90°
            
            // altitude fine-tuning with smooth curve
            let altFine = sin(orbitalPhase * (.pi / 2.0))
            alt = 248.0 + altFine * 20.0      // 248km to 268km (stable orbit)
            
            // final downrange distance
            let downrangeFine = 1.0 - cos(orbitalPhase * (.pi / 2.0))
            downrange = 700.0 + downrangeFine * 500.0  // 700km to 1200km
            
            vel = 27700.0 + orbitalPhase * 200.0  // 27700 to 27900 km/h (orbital velocity)
        }
        
        // --- position calculation with smooth curves ---
        let scale: Float = 0.5
        
        // y is vertical altitude
        let yPos = Float(alt) * scale
        
        // z is horizontal distance traveled (downrange)
        // uses smooth curve based on pitch angle
        let pitchRad = pitch * .pi / 180.0
        let zPos = Float(downrange * sin(pitchRad)) * scale * -0.5
        
        // map pitch to scnvector4 for rotation around x axis
        let pitchRadFloat = Float(pitchRad)
        let rotation = SCNVector4(1, 0, 0, -pitchRadFloat)
        
        return TrajectoryState(
            altitude: alt,
            velocity: vel,
            position: SCNVector3(x: 0, y: yPos, z: zPos),
            rotation: rotation,
            tiltAngle: pitch
        )
    }
}
