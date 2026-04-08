import SwiftUI

// compact part detail sheet
struct RocketPartSheetView: View {
    let part: RocketPart
    let accentColor: Color
    
    @Environment(\.dismiss) private var dismiss
    
    private var partImage: String? {
        if let name = part.partImageName, UIImage(named: name) != nil {
            return name
        }
        if let name = part.stageImageName, UIImage(named: name) != nil {
            return name
        }
        let fallback = "slice_" + part.name.lowercased().replacingOccurrences(of: " ", with: "_")
        if UIImage(named: fallback) != nil {
            return fallback
        }
        return nil
    }
    
    var body: some View {
        NavigationStack {
            List {
                // header image
                VStack {
                    if let img = partImage {
                        Image(img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .shadow(color: accentColor.opacity(0.3), radius: 10)
                    } else {
                        Image(systemName: part.icon)
                            .font(.system(size: 80))
                            .foregroundColor(accentColor)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.bottom, 10)
                
                // description section
                Section {
                    Text(part.description)
                        .font(.body)
                }
                
                // specifications section
                if !part.specs.isEmpty {
                    Section(header: Text("Specifications")) {
                        ForEach(part.specs, id: \.id) { spec in
                            HStack {
                                Text(spec.label)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(spec.value)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                
                // components section
                if !part.subparts.isEmpty {
                    Section(header: Text("Components")) {
                        ForEach(part.subparts, id: \.id) { sub in
                            HStack(spacing: 16) {
                                Image(systemName: sub.icon)
                                    .font(.title2)
                                    .foregroundColor(accentColor)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(sub.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                    if let firstSpec = sub.specs.first {
                                        Text(firstSpec.value)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(part.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
    }
}

