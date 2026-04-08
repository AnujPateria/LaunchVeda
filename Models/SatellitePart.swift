
import Foundation
import SwiftUI

struct SatellitePart: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let description: String
    let icon: String // sf symbol
    
    // physical properties for 3d construction
    enum Shape: String, Hashable, Sendable {
        case box
        case cylinder
        case sphere
        case panel // flat rect
        case dish // parabolic dish (represented as flattened sphere/cone)
        case capsule // for rover/lander body if needed
    }
    
    let shape: Shape
    let width: CGFloat   // x dimension or diameter
    let height: CGFloat  // y dimension
    let length: CGFloat  // z dimension
    let color: Color
    
    // position relative to parent container (or center if root)
    let position: SIMD3<Float> 
    
    // sub-components (e.g. rover inside lander)
    let subparts: [SatellitePart]
    
    // specs for detail view
    let specs: [RocketSpec] // reusing rocketspec as it's just label/value
    
    // helper for color
    var uiColor: UIColor {
        UIColor(color)
    }
}
