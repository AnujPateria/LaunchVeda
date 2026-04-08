import SwiftUI

// 2d realistic rocket explorer
struct Realistic2DRocketExplorer: View {
    var rocketName: String?
    var parts: [RocketPart] = []
    let accentColor: Color
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPart: RocketPart? = nil
    @State private var navigationStack: [RocketPart] = []
    @State private var showDetailView = false
    @State private var selectedTab: ExplorerTab = .overview
    @State private var scrollPosition: CGFloat = 0
    
    enum ExplorerTab: String, CaseIterable {
        case overview = "Overview"
        case diagram = "Diagram"
        case specs = "Specs"
    }
    
    var title: String { rocketName ?? "Rocket Explorer" }
    var overview: RocketOverview? { rocketName.flatMap { MockData.rocketOverview(for: $0) } }
    
    var body: some View {
        ZStack {
            // background
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // header
                headerBar
                
                // tab selector
                tabSelector
                
                // content
                ZStack {
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .diagram:
                        diagramContent
                    case .specs:
                        specsContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    
    // header
    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text("Rocket Explorer")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            if !navigationStack.isEmpty {
                Button(action: { navigationStack.removeLast() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 10))
                        Text("Back")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(accentColor.opacity(0.3)))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // tab selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ExplorerTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(.system(size: 12, weight: selectedTab == tab ? .bold : .medium))
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(accentColor.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(accentColor.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // overview content
    @ViewBuilder
    private var overviewContent: some View {
        if let ov = overview {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    // rocket stats
                    rocketStatsGrid(ov)
                    
                    // description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(ov.description)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                    
                    // key facts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Facts")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        factRow(icon: "calendar", label: "First Flight", value: ov.firstFlight)
                        factRow(icon: "number", label: "Total Launches", value: ov.totalLaunches)
                        factRow(icon: "checkmark.seal.fill", label: "Success Rate", value: ov.successRate)
                        factRow(icon: "power", label: "Status", value: ov.status, color: ov.status == "Active" ? .green : .blue)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
                }
                .padding(16)
            }
        }
    }
    
    // diagram content (interactive 2d rocket)
    @ViewBuilder
    private var diagramContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rocket Structure")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
                // 2d rocket diagram
                rocketDiagram
                
                // parts list
                Text("Components")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                
                partsList
            }
            .padding(.vertical, 16)
        }
    }
    
    // specs content
    @ViewBuilder
    private var specsContent: some View {
        if let ov = overview {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    specRow(label: "Height", value: ov.height, icon: "ruler")
                    specRow(label: "Diameter", value: ov.diameter, icon: "arrow.left.and.right")
                    specRow(label: "Liftoff Mass", value: ov.liftoffMass, icon: "scalemass")
                    specRow(label: "Liftoff Thrust", value: ov.liftoffThrust, icon: "flame.fill")
                    specRow(label: "Payload LEO", value: ov.payloadLEO, icon: "globe")
                    specRow(label: "Payload GTO", value: ov.payloadGTO, icon: "circle.dashed")
                    specRow(label: "Stages", value: "\(ov.stages)", icon: "square.stack.3d.up")
                }
                .padding(16)
            }
        }
    }

    
    // helper views
    private func rocketStatsGrid(_ ov: RocketOverview) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(icon: "ruler", label: "HEIGHT", value: ov.height, color: accentColor)
                statCard(icon: "scalemass", label: "MASS", value: ov.liftoffMass, color: .orange)
                statCard(icon: "flame.fill", label: "THRUST", value: ov.liftoffThrust, color: .red)
            }
            
            HStack(spacing: 12) {
                statCard(icon: "shippingbox.fill", label: "LEO", value: ov.payloadLEO, color: .green)
                statCard(icon: "circle.dashed", label: "GTO", value: ov.payloadGTO, color: .cyan)
                statCard(icon: "square.stack.3d.up", label: "STAGES", value: "\(ov.stages)", color: .purple)
            }
        }
        .padding(16)
    }
    
    private func statCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.1)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(color.opacity(0.3), lineWidth: 1))
    }
    
    private func factRow(icon: String, label: String, value: String, color: Color? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color ?? accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(0.5)
                
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private var rocketDiagram: some View {
        VStack(spacing: 0) {
            ForEach(Array(parts.enumerated()), id: \.element.id) { index, part in
                rocketPartCard(part, index: index)
            }
        }
        .padding(.horizontal, 16)
    }

    private func rocketPartCard(_ part: RocketPart, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4)) {
                navigationStack.append(part)
            }
        }) {
            HStack(spacing: 14) {
                // part number
                ZStack {
                    Circle()
                        .fill(part.swiftUIColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(Circle().strokeBorder(part.swiftUIColor.opacity(0.5), lineWidth: 1.5))

                    Text("\(index + 1)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(part.swiftUIColor)
                }

                // part info
                VStack(alignment: .leading, spacing: 4) {
                    Text(part.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Text(part.description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                // icon and chevron
                VStack(spacing: 4) {
                    Image(systemName: part.icon)
                        .font(.system(size: 14))
                        .foregroundColor(part.swiftUIColor)

                    if !part.subparts.isEmpty {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(part.swiftUIColor.opacity(0.2), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 6)
    }
    
    private var partsList: some View {
        VStack(spacing: 8) {
            ForEach(parts, id: \.id) { part in
                partListItem(part)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func partListItem(_ part: RocketPart) -> some View {
        HStack(spacing: 10) {
            Image(systemName: part.icon)
                .font(.system(size: 14))
                .foregroundColor(part.swiftUIColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(part.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                
                if !part.specs.isEmpty {
                    Text("\(part.specs.count) specifications")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            if !part.subparts.isEmpty {
                Text("\(part.subparts.count) subparts")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(accentColor.opacity(0.2)))
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
    }
    
    private func specRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(accentColor)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
    }

}
