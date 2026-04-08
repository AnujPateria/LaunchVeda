import SwiftUI

struct UIManager: View {
    let state: TrajectoryState
    let currentStage: Int
    let time: TimeInterval
    @Binding var selectedPartName: String?
    @Binding var cameraMode: CameraMode
    @Binding var isSoundEnabled: Bool
    
    enum CameraMode: String, CaseIterable {
        case side = "Side View"
        case follow = "Follow Rocket"
        case zoom = "Stage Separation Zoom"
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                // left mission data panel
                VStack(alignment: .leading, spacing: 8) {
                    Text("MISSION TELEMETRY")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.gray)
                    
                    hudRow(label: "T+", value: formatTime(time))
                    hudRow(label: "VELOCITY", value: String(format: "%.0f km/h", state.velocity))
                    hudRow(label: "ALTITUDE", value: String(format: "%.1f km", state.altitude))
                    hudRow(label: "PITCH", value: String(format: "%.1f°", state.tiltAngle))
                    hudRow(label: "STAGE", value: "\(currentStage)")
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
                
                // right  control
                VStack(alignment: .trailing, spacing: 12) {
                    // sound toggl
                    Button(action: { isSoundEnabled.toggle() }) {
                        Image(systemName: isSoundEnabled ? "speaker.wave.3.fill" : "speaker.slash.fill")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    
                    // camera toggle
                    VStack(spacing: 8) {
                        ForEach(CameraMode.allCases, id: \.self) { mode in
                            Button(action: {
                                withAnimation { cameraMode = mode }
                            }) {
                                Text(mode.rawValue)
                                    .font(.caption)
                                    .bold()
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(cameraMode == mode ? SpaceTheme.electricBlue : Color.white.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
            }
            .padding()
            
            Spacer()
            
            //  stage info panel (pop-up on click)
            if let part = selectedPartName {
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("COMPONENT DATA")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.gray)
                            Spacer()
                            Button(action: { selectedPartName = nil }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        Text(part)
                            .font(.headline)
                            .bold()
                            .foregroundColor(SpaceTheme.electricBlue)
                        
                        let data = getPartData(for: part)
                        hudRow(label: "FUEL", value: data.fuel)
                        hudRow(label: "THRUST", value: data.thrust)
                        hudRow(label: "STATUS", value: currentStage > data.activeStage ? "Separated" : "Active")
                    }
                    .padding()
                    .frame(width: 200)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
    }
    
    private func hudRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .monospacedDigit()
        }
    }
    
    private func formatTime(_ t: TimeInterval) -> String {
        let m = Int(t) / 60
        let s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    // mock data for clicked parts
    private func getPartData(for partName: String) -> (fuel: String, thrust: String, activeStage: Int) {
        switch partName {
        case "Stage 1": return ("RP-1 / LOX", "7,600 kN", 1)
        case "Stage 2": return ("LH2 / LOX", "980 kN", 2)
        case "Fairing": return ("None", "0 kN", 1) // falls off during stage 2
        default: return ("Unknown", "Unknown", 1)
        }
    }
}
