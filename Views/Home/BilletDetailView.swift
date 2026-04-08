import SwiftUI

struct BilletDetailView: View {
    let billet: Billet
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StarFieldBackground()
            
            VStack(spacing: 0) {
                headerBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // icon & title
                        VStack(spacing: 12) {
                            Image(systemName: billet.icon)
                                .font(.system(size: 64))
                                .foregroundColor(billet.authority.color)
                                .frame(width: 100, height: 100)
                                .background(Circle().fill(billet.authority.color.opacity(0.15)))
                                .padding(.top, 24)
                            
                            Text(billet.title)
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(billet.authority.color)
                                    .frame(width: 10, height: 10)
                                Text("AUTHORITY: \(billet.authority.rawValue)")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(billet.authority.color)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(billet.authority.color.opacity(0.15)))
                            .overlay(Capsule().strokeBorder(billet.authority.color.opacity(0.4), lineWidth: 1))
                        }
                        
                        // 2. controls / systems (most critical)
                        if !billet.controls.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle(icon: "slider.horizontal.3", label: "Systems Controlled", color: .white)
                                
                                VStack(spacing: 8) {
                                    ForEach(billet.controls, id: \.self) { system in
                                        HStack(spacing: 12) {
                                            Image(systemName: "cpu")
                                                .font(.system(size: 14))
                                                .foregroundColor(SpaceTheme.electricBlue)
                                            Text(system)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        .padding(14)
                                        .glassCard(cornerRadius: 12)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // 3. mission phase activity (timeline bar)
                        if !billet.activePhases.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle(icon: "clock.fill", label: "Active Phases", color: .white)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        let allPhases = ["Pre-Launch", "Launch", "Orbit", "Landing", "Recovery"]
                                        ForEach(allPhases, id: \.self) { phase in
                                            let isActive = billet.activePhases.contains(phase)
                                            VStack(spacing: 8) {
                                                Circle()
                                                    .fill(isActive ? SpaceTheme.successGreen : Color.white.opacity(0.1))
                                                    .frame(width: 12, height: 12)
                                                Text(phase)
                                                    .font(.system(size: 11, weight: isActive ? .bold : .medium))
                                                    .foregroundColor(isActive ? .white : .white.opacity(0.4))
                                            }
                                            .frame(width: 80)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 14)
                                    .glassCard(cornerRadius: 16)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // 4 & 5. reports to (command chain)
                        if !billet.reportsTo.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle(icon: "arrow.turn.up.right", label: "Reports To", color: .white)
                                
                                HStack(spacing: 14) {
                                    Image(systemName: "person.badge.shield.checkmark.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(SpaceTheme.electricBlue)
                                    Text(billet.reportsTo)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(14)
                                .glassCard(cornerRadius: 12)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // 6. handles failures
                        if !billet.handlesFailures.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionTitle(icon: "exclamationmark.triangle.fill", label: "Handles Failures", color: .red)
                                
                                VStack(spacing: 8) {
                                    ForEach(billet.handlesFailures, id: \.self) { anomaly in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "xmark.shield.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.red.opacity(0.8))
                                                .padding(.top, 2)
                                            Text(anomaly)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white.opacity(0.9))
                                            Spacer()
                                        }
                                        .padding(14)
                                        .glassCard(cornerRadius: 12)
                                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.red.opacity(0.3), lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    private func sectionTitle(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
            Text(label.uppercased())
                .font(.system(size: 12, weight: .heavy, design: .rounded))
        }
        .foregroundColor(color.opacity(0.8))
        .tracking(0.5)
    }
}
