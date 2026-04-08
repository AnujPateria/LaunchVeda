import SwiftUI

// anatomy sub-part view (drill-down)
struct AnatomySubPartView: View {
    let part: AnatomySection
    let accentColor: Color
    @State private var selectedSubPart: AnatomySubPart? = nil
    
    var body: some View {
        ZStack {
            StarFieldBackground()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(part.name.uppercased())
                            .font(.system(size: 12, weight: .heavy, design: .monospaced))
                            .foregroundColor(accentColor)
                            .tracking(2)
                        
                        Text("Sub-System Breakdown")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(part.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.75))
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // exploded diagram
                    VStack(spacing: 0) {
                        Text("EXPLODED VIEW")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundColor(SpaceTheme.subtleGray)
                            .tracking(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 12)
                        
                        // visual exploded diagram
                        VStack(spacing: 20) {
                            ForEach(Array(part.subParts.enumerated()), id: \.element.id) { index, subPart in
                                let isSelected = selectedSubPart?.id == subPart.id
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        selectedSubPart = isSelected ? nil : subPart
                                    }
                                }) {
                                    ExplodedAnatomyRow(
                                        subPart: subPart,
                                        isSelected: isSelected,
                                        accentColor: accentColor
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // expanded info when selected
                                if isSelected {
                                    AnatomySubPartInfoCard(subPart: subPart, accentColor: accentColor)
                                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                        .padding(.horizontal, 24)
                                }
                                
                                // dotted connector between sub-parts (except last)
                                if index < part.subParts.count - 1 && !isSelected {
                                    AnatomyDottedLine(color: accentColor.opacity(0.3))
                                        .frame(height: 20)
                                        .padding(.horizontal, 40)
                                }
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    
                    Spacer(minLength: 80)
                }
            }
        }
        .navigationTitle(part.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbarBackground(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }
}

// exploded sub-part row
struct ExplodedAnatomyRow: View {
    let subPart: AnatomySubPart
    let isSelected: Bool
    let accentColor: Color
    
    private var partColor: Color {
        anatomyPartColor(for: subPart.systemType)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // visual block
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                isSelected ? accentColor.opacity(0.5) : partColor.opacity(0.3),
                                isSelected ? accentColor.opacity(0.25) : partColor.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(isSelected ? accentColor : partColor.opacity(0.4), lineWidth: 1)
                    )
                
                Image(systemName: anatomyIcon(for: subPart.systemType))
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .white : partColor)
            }
            .shadow(color: isSelected ? accentColor.opacity(0.4) : .clear, radius: 10)
            
            // label
            VStack(alignment: .leading, spacing: 4) {
                Text(subPart.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Text(subPart.systemType.uppercased())
                        .font(.system(size: 10, weight: .heavy, design: .monospaced))
                        .foregroundColor(isSelected ? accentColor : SpaceTheme.subtleGray)
                        .tracking(1)
                    
                    if isSelected {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(accentColor)
                    }
                }
            }
            
            Spacer()
            
            // tap indicator
            Image(systemName: isSelected ? "minus.circle.fill" : "plus.circle")
                .font(.system(size: 20))
                .foregroundColor(isSelected ? accentColor : SpaceTheme.subtleGray.opacity(0.5))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

// sub-part info card
struct AnatomySubPartInfoCard: View {
    let subPart: AnatomySubPart
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 3, height: 18)
                
                Text("TECHNICAL DETAILS")
                    .font(.system(size: 10, weight: .heavy, design: .monospaced))
                    .foregroundColor(accentColor)
                    .tracking(1.5)
            }
            
            Text(subPart.detailText)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
            
            // data pills
            HStack(spacing: 10) {
                anatomyDataPill(label: "Type", value: subPart.systemType, accentColor: accentColor)
                anatomyDataPill(label: "Component", value: subPart.name, accentColor: accentColor)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}

private func anatomyDataPill(label: String, value: String, accentColor: Color) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(label.uppercased())
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(SpaceTheme.subtleGray)
            .tracking(1)
        Text(value)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(1)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Color.white.opacity(0.05))
    .cornerRadius(8)
}

// dotted connector
struct AnatomyDottedLine: View {
    let color: Color
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let midX = geo.size.width / 2
                path.move(to: CGPoint(x: midX, y: 0))
                path.addLine(to: CGPoint(x: midX, y: geo.size.height))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        }
    }
}
