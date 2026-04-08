import SwiftUI

struct PartInteractiveDetailView: View {
    let part: RocketPart
    let accentColor: Color
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBillet: Billet? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            StarFieldBackground()
            
            VStack(spacing: 0) {
                headerBar
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // image section
                        if let imageName = part.partImageName ?? part.stageImageName, UIImage(named: imageName) != nil {
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .shadow(color: accentColor.opacity(0.3), radius: 20)
                                .padding(.top, 20)
                        } else if let sliceName = part.partImageName ?? part.stageImageName, UIImage(named: "slice_\(sliceName)") != nil {
                            Image("slice_\(sliceName)")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .shadow(color: accentColor.opacity(0.3), radius: 20)
                                .padding(.top, 20)
                        } else {
                            // extract just the part logic and format its name as an image
                            let fallbackSliceName = "slice_" + part.name.lowercased().replacingOccurrences(of: " ", with: "_")
                            if UIImage(named: fallbackSliceName) != nil {
                                Image(fallbackSliceName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 250)
                                    .shadow(color: accentColor.opacity(0.3), radius: 20)
                                    .padding(.top, 20)
                            } else {
                                Image(systemName: part.icon)
                                    .font(.system(size: 80))
                                    .foregroundColor(accentColor)
                                    .frame(height: 200)
                                    .padding(.top, 20)
                            }
                        }
                        
                        // description
                        Text(part.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .lineSpacing(4)
                        
                        // specs
                        if !part.specs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Specifications")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .foregroundColor(accentColor)
                                    .padding(.horizontal, 24)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(part.specs, id: \.id) { spec in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(spec.label.uppercased())
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white.opacity(0.5))
                                            Text(spec.value)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .glassCard(cornerRadius: 16)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // controlled by
                        if let controllers = part.controlledBy, !controllers.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Controlled By")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                                    .foregroundColor(accentColor)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 8) {
                                    ForEach(controllers, id: \.self) { billetId in
                                        if let billet = MockData.billets.first(where: { $0.id == billetId }) {
                                            Button(action: {
                                                selectedBillet = billet
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: billet.icon)
                                                        .font(.system(size: 16))
                                                        .foregroundColor(billet.authority.color)
                                                        .frame(width: 32, height: 32)
                                                        .background(Circle().fill(billet.authority.color.opacity(0.15)))
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(billet.title)
                                                            .font(.subheadline)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                        Text("Authority: \(billet.authority.rawValue)")
                                                            .font(.caption)
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(billet.authority.color)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white.opacity(0.3))
                                                }
                                                .padding(12)
                                                .glassCard(cornerRadius: 14)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        

                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedBillet) { billet in
            BilletDetailView(billet: billet)
        }
    }
    
    private var headerBar: some View {
        HStack(alignment: .center, spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(part.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text("Component Detail")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
