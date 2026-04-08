import SceneKit
import SwiftUI

@MainActor
class InteractionHandler {
    
    var selectedNodeName: Binding<String?>
    
    init(selectedNodeName: Binding<String?>) {
        self.selectedNodeName = selectedNodeName
    }
    
    func handleTap(at location: CGPoint, in scnView: SCNView) {
        let hits = scnView.hitTest(location, options: [.searchMode: SCNHitTestSearchMode.closest.rawValue as NSNumber])
        
        var tappedName: String? = nil
        for hit in hits {
            var node: SCNNode? = hit.node
            while node != nil {
                if let name = node?.name, name == "Stage 1" || name == "Stage 2" || name == "Fairing" {
                    tappedName = name
                    break
                }
                node = node?.parent
            }
            if tappedName != nil { break }
        }
        
        DispatchQueue.main.async {
            self.selectedNodeName.wrappedValue = tappedName
        }
    }
}
