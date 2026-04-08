import SwiftUI

struct PartInformationView: View {
    let part: LaunchReplayView.TappedPartInfo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // header hero
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(LinearGradient(colors: [part.accentColor.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                                .frame(height: 220)
                            
                            HStack(alignment: .bottom, spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.3))
                                        .frame(width: 80, height: 80)
                                        .shadow(color: part.accentColor.opacity(0.5), radius: 10)
                                        
                                    Image(systemName: part.icon)
                                        .font(.system(size: 36))
                                        .foregroundColor(part.accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("COMPONENT ANALYSIS")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(part.accentColor)
                                        .tracking(2)
                                    Text(part.name)
                                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                        }
                        
                        // description section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("OVERVIEW")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1)
                            
                            Text(part.description)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.1), lineWidth: 1))
                        }
                        .padding(.horizontal, 24)
                        
                        // specs grid
                        if !part.specs.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("SPECIFICATIONS")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(part.specs, id: \.0) { spec in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(spec.0.uppercased())
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(part.accentColor.opacity(0.8))
                                                .tracking(0.5)
                                            Text(spec.1)
                                                .font(.system(size: 17, weight: .bold, design: .monospaced))
                                                .foregroundColor(.white)
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                        }
                                        .padding(.vertical, 16)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.04))
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 60)
                    }
                }
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
#else
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
#endif
            }
        }
        .preferredColorScheme(.dark)
    }
}
