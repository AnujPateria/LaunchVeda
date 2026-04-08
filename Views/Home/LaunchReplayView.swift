import SwiftUI
import SceneKit
import QuartzCore
#if canImport(UIKit)
import UIKit
import CoreHaptics
#endif

struct LaunchReplayView: View {
    let launch: Launch
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentTime: Double = 0
    @State private var isPlaying = false
    @State private var playbackSpeed: Double = 1.0
    @State private var sceneBuilder: TrajectorySceneBuilder?
#if os(macOS)
    @State private var displayLink: Timer?
#else
    @State private var displayLink: CADisplayLink?
#endif
    @State private var lastFrameTime: CFTimeInterval = 0
    @State private var showStagePanel = false
    @State private var showComingSoonAlert = false
    @State private var showApollo11Replay = false
    @State private var isLooping = true
    // tap-to-inspect
    @State private var tappedPartInfo: TappedPartInfo? = nil
    @State private var selectedRocketPart: RocketPart? = nil
    // zoom hint animation
    @State private var zoomHintScale: CGFloat = 1.15
    @State private var showZoomHint = true
    
    @State private var selectedDataInsight: DataInsight? = nil
    @State private var showDataInsightDetail = false
    
    // sound
    @StateObject private var soundManager = LaunchSoundManager()
    @State private var showVolumeSlider = false
    
    struct TappedPartInfo: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let description: String
        let specs: [(String, String)]
        let accentColor: Color
    }
    
    struct DataInsight: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let highlightValue: String
        let summary: String
        let details: [(String, String)]
        let accentColor: Color
    }
    
    private enum MetricKind {
        case altitude
        case velocity
        case downrange
        case activeStages
    }
    
    private struct RealStageSnapshot: Identifiable {
        let id: String
        let name: String
        let ignition: StageEvent?
        let separation: StageEvent?
        let status: String
        let statusColor: Color
    }
    
    private var stageEvents: [StageEvent] {
        StageEvent.events(for: launch.rocketName)
    }
    
    private var trajectoryPoints: [TrajectoryPoint] {
        FlightProfileGenerator.generateProfile(
            rocketName: launch.rocketName,
            trajectory: launch.trajectory,
            stageEvents: stageEvents
        )
    }
    
    private var maxTime: Double {
        trajectoryPoints.last?.time ?? 600
    }
    
    private var currentPoint: TrajectoryPoint? {
        trajectoryPoints.last(where: { $0.time <= currentTime })
    }
    
    private var replayRocketParts: [RocketPart] {
        let exact = MockData.rocketParts(for: launch.rocketName)
        if !exact.isEmpty { return exact }
        
        let model = launch.rocketName.lowercased()
        if model.contains("falcon") { return MockData.falcon9Parts }
        if model.contains("saturn") { return MockData.saturnVParts }
        if model.contains("lvm") { return MockData.lvm3Parts }
        if model.contains("pslv") { return MockData.pslvXLParts }
        if model.contains("atlas") { return MockData.atlasV541Parts }
        if model.contains("ariane") { return MockData.ariane5Parts }
        if model.contains("h-ii") { return MockData.hIIAParts }
        if model.contains("sls") { return MockData.slsParts }
        return []
    }
    
    private var separatedStages: [StageEvent] {
        stageEvents.filter { $0.time <= currentTime && ($0.eventType == .separation || $0.eventType == .jettison) }
    }
    
    // current active stages at this time
    private var activeStageNames: [String] {
        currentPoint?.activeStages ?? []
    }
    
    private var realStageSnapshots: [RealStageSnapshot] {
        let stages = RocketStageData.stages(for: launch.rocketName)
        guard !stages.isEmpty else { return [] }
        
        let ignitionEvents = stageEvents.filter { $0.eventType == .ignition }
        let separationEvents = stageEvents.filter {
            $0.eventType == .separation || $0.eventType == .jettison || $0.eventType == .deployment
        }
        
        return stages.enumerated().map { index, stage in
            var ignition = ignitionEvents.first {
                stageEventMatchesStage(eventName: $0.stageName, stageName: stage.name)
            }
            var separation = separationEvents.first {
                stageEventMatchesStage(eventName: $0.stageName, stageName: stage.name)
            }
            
            // fallback alignment by order if names differ between datasets.
            if ignition == nil && index < ignitionEvents.count {
                ignition = ignitionEvents[index]
            }
            if separation == nil {
                let filtered = separationEvents.filter { $0.time > (ignition?.time ?? 0) }
                if index < filtered.count {
                    separation = filtered[index]
                }
            }
            
            let status: String
            let statusColor: Color
            if let sep = separation, currentTime >= sep.time {
                status = "Separated"
                statusColor = .orange
            } else if let ign = ignition, currentTime >= ign.time {
                status = "Active"
                statusColor = .green
            } else {
                status = "Pending"
                statusColor = .yellow
            }
            
            return RealStageSnapshot(
                id: normalize(stage.name).isEmpty ? "\(index)" : normalize(stage.name),
                name: stage.name,
                ignition: ignition,
                separation: separation,
                status: status,
                statusColor: statusColor
            )
        }
    }
    
    // current flight phase description — dynamic for all rockets
    private var currentPhaseDescription: String {
        let t = currentTime
        if t <= 0 { return "T-0 Hold · All systems nominal" }
        
        // find the most recent event and the next upcoming one
        let pastEvents = stageEvents.filter { $0.time <= t }
        let nextEvent = stageEvents.first(where: { $0.time > t })
        
        guard let latest = pastEvents.last else {
            return "Liftoff · All engines running"
        }
        
        // build a description based on the latest event
        let altitude = currentPoint?.y ?? 0
        let phase: String
        
        if t < 5 {
            phase = "Liftoff · All engines running"
        } else if t < 60 {
            phase = "Max-Q · Maximum aerodynamic pressure"
        } else if let next = nextEvent {
            let timeToNext = Int(next.time - t)
            phase = "\(latest.stageName) · \(latest.eventType.rawValue) — next event in \(timeToNext)s"
        } else {
            // past all events
            if altitude > 150 {
                phase = "Orbit achieved · \(Int(altitude)) km altitude"
            } else {
                phase = "\(latest.stageName) · \(latest.eventType.rawValue)"
            }
        }
        
        return phase
    }

    private var dataPanelTopInset: CGFloat {
#if os(macOS)
        72
#else
        78
#endif
    }

    private var dataPanelHeight: CGFloat? {
#if os(macOS)
        580
#else
        nil // nil means it will take its intrinsic size but we'll limit it via .frame(maxheight: ...)
#endif
    }

    private var headerSpeedText: String {
        String(format: "%.0f km/h", currentPoint?.velocity ?? 0)
    }

    private var headerAltitudeText: String {
        String(format: "%.0f km", currentPoint?.y ?? 0)
    }

    private var volumeIcon: String {
        if soundManager.volume < 0.01 { return "speaker.fill" }
        if soundManager.volume < 0.4 { return "speaker.wave.1.fill" }
        if soundManager.volume < 0.7 { return "speaker.wave.2.fill" }
        return "speaker.wave.3.fill"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    replaySceneView
                    overlayHUD
                }
                timelineBar
            }
            
            
            // side panel replaced by .sheet modifier
        }
        .sheet(isPresented: $showStagePanel) {
            stageInfoPanel
#if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
#else
                .frame(minWidth: 350, minHeight: 400)
#endif
        }
        .alert("Available Soon", isPresented: $showComingSoonAlert) {
            Button("View Apollo 11 Data") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showApollo11Replay = true
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("The mission data for \(launch.missionName) is currently in development. Would you like to view the Apollo 11 data instead?")
        }
        .fullScreenCover(isPresented: $showApollo11Replay) {
            if let apollo11 = MockData.allMissions.first(where: { $0.name == "Apollo 11" }) {
                NavigationStack {
                    LaunchReplayView(launch: Launch(
                        missionName: apollo11.name,
                        rocketName: apollo11.rocketModel,
                        agency: apollo11.agencyName,
                        agencyAbbr: apollo11.agencyAbbr,
                        launchDate: Date(),
                        launchSite: apollo11.launchSiteStr,
                        status: .completed,
                        description: apollo11.description,
                        trajectory: [],
                        orbitType: apollo11.orbit,
                        maxAltitude: "",
                        targetDestination: apollo11.orbit,
                        imageName: apollo11.imageName
                    ))
                }
            }
        }
        .sheet(item: $tappedPartInfo) { part in
            PartInformationView(part: part)
        }
#if os(macOS)
        .sheet(item: $selectedRocketPart) { part in
            NavigationStack {
                PartInteractiveDetailView(part: part, accentColor: part.swiftUIColor)
                    .frame(minWidth: 800, minHeight: 600)
            }
        }
#else
        .fullScreenCover(item: $selectedRocketPart) { part in
            NavigationStack {
                PartInteractiveDetailView(part: part, accentColor: part.swiftUIColor)
            }
        }
#endif
        .preferredColorScheme(.dark)
        .navigationTitle(launch.missionName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.body.weight(.semibold))
                        .foregroundColor(SpaceTheme.electricBlue)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(launch.missionName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 6) {
                        Text("T+\(formatTime(currentTime))")
                            .foregroundColor(SpaceTheme.electricBlue)
                        
                        Text("SPD \(headerSpeedText)")
                            .foregroundColor(.secondary)
                        
                        Text("ALT \(headerAltitudeText)")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2.monospacedDigit().weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if isPlaying { stopPlayback() }
                    if launch.missionName.localizedCaseInsensitiveContains("Chandrayaan-2") {
                        showComingSoonAlert = true
                    } else {
                        showStagePanel.toggle()
                    }
                }) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.body)
                        .foregroundColor(SpaceTheme.electricBlue)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            setupScene()
            // auto-start playback after a brief delay for scene to initialize
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startPlayback()
            }
        }
        .onDisappear { stopPlayback() }
    }
    
    // eliminated custom `navbar` completely in favor of `.toolbar` modifiers.
    
    // scenekit view with tap
    private var replaySceneView: some View {
        Group {
            if let builder = sceneBuilder {
                LaunchReplay3DSceneView(
                    scene: builder.scene,
                    onTapNode: { nodeName in
                        handleNodeTap(nodeName: nodeName)
                    },
                    onViewCreated: { view in
                        builder.scnView = view
                    }
                )
                .scaleEffect(zoomHintScale)
                .onAppear {
                    // zoom hint: start zoomed in, ease back to normal
                    withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
                        zoomHintScale = 1.0
                    }
                    // hide the pinch hint after 2.5s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showZoomHint = false
                        }
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
    }
    
    // hud overlay
    private var overlayHUD: some View {
        VStack {
            Spacer()
            
            // event notification
            if let latestEvent = stageEvents.last(where: { abs($0.time - currentTime) < 5 }) {
                HStack(spacing: 10) {
                    Image(systemName: latestEvent.icon)
                        .font(.system(size: 14))
                        .foregroundColor(latestEvent.color)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(latestEvent.stageName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(latestEvent.eventType.rawValue) at T+\(formatTime(latestEvent.time))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(latestEvent.color)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(latestEvent.color.opacity(0.3), lineWidth: 1))
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 10)
            }
            
            // zoom hint (shows briefly on entry)
            if showZoomHint {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.left.and.arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Pinch to zoom")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }

            // tap hint
            if tappedPartInfo == nil && !isPlaying && !showZoomHint {
                HStack(spacing: 6) {
                    Image(systemName: "hand.tap.fill")
                        .font(.caption2)
                    Text("Tap any part to inspect")
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 16)
                .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    // timeline bar
    private var timelineBar: some View {
        VStack(spacing: 10) {
            // event markers on timeline
            GeometryReader { geo in
                let w = geo.size.width - 32
                ZStack(alignment: .leading) {
                    // track
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 4)
                        .padding(.horizontal, 16)
                    
                    // progress
                    Capsule()
                        .fill(SpaceTheme.electricBlue)
                        .frame(width: max(0, CGFloat(currentTime / maxTime) * w), height: 4)
                        .padding(.leading, 16)
                    
                    // event dots
                    ForEach(stageEvents) { event in
                        let xPos = CGFloat(event.time / maxTime) * w + 16
                        Circle()
                            .fill(event.color)
                            .frame(width: 8, height: 8)
                            .offset(x: xPos - 4)
                    }
                    
                    // scrubber head
                    let scrubX = CGFloat(currentTime / maxTime) * w + 16
                    Circle()
                        .fill(.white)
                        .frame(width: 14, height: 14)
                        .shadow(color: SpaceTheme.electricBlue.opacity(0.6), radius: 4)
                        .offset(x: scrubX - 7)
                }
                .frame(height: 14)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
#if os(macOS)
                            let pct = max(0, min(1, (value.location.x - 16) / (800 - 52)))
#else
                            let pct = max(0, min(1, (value.location.x - 16) / (geo.size.width - 52)))
#endif
                            currentTime = Double(pct) * maxTime
                            sceneBuilder?.updateRocketPosition(at: currentTime)
                        }
                )
            }
            .frame(height: 14)
            
            HStack(spacing: 24) {
                // reset
                Button {
                    resetPlayback()
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                // play/pause
                Button {
                    if isPlaying { stopPlayback() } else { startPlayback() }
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.primary)
                }
                
                // speed
                Button {
                    playbackSpeed = playbackSpeed >= 4 ? 1 : playbackSpeed * 2
                } label: {
                    Text("\(Int(playbackSpeed))×")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(minWidth: 32)
                }
                
                // volume
                Button {
                    showVolumeSlider.toggle()
                } label: {
                    Image(systemName: soundManager.isMuted ? "speaker.slash.fill" : volumeIcon)
                        .font(.title3)
                        .foregroundColor(soundManager.isMuted ? .secondary : .primary)
                }
                .popover(isPresented: $showVolumeSlider) {
                    VStack(spacing: 12) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(
                            value: Binding<Double>(
                                get: { Double(soundManager.volume) },
                                set: { soundManager.volume = Float($0) }
                            ),
                            in: 0.0...1.0
                        )
                        .frame(width: 120)
                        .tint(SpaceTheme.electricBlue)
                        Image(systemName: "speaker.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button {
                            soundManager.toggleMute()
                        } label: {
                            Text(soundManager.isMuted ? "Unmute" : "Mute")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(SpaceTheme.electricBlue)
                        }
                    }
                    .padding(16)
                    .presentationCompactAdaptation(.popover)
                }
                
                Spacer()
                
                Text(launch.rocketName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        // native full-width gradient context instead of floating pill box
        .background(
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.7), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private var flightDataSummaryView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                dataTile(
                    label: "Altitude",
                    value: String(format: "%.0f km", currentPoint?.y ?? 0),
                    color: .cyan
                ) {
                    openDataInsight(metricInsight(for: .altitude))
                }
                dataTile(
                    label: "Velocity",
                    value: String(format: "%.0f km/h", currentPoint?.velocity ?? 0),
                    color: .orange
                ) {
                    openDataInsight(metricInsight(for: .velocity))
                }
            }
            HStack(spacing: 12) {
                dataTile(
                    label: "Downrange",
                    value: String(format: "%.0f km", currentPoint?.x ?? 0),
                    color: .green
                ) {
                    openDataInsight(metricInsight(for: .downrange))
                }
                dataTile(
                    label: "Stages",
                    value: "\(activeStageNames.count) Active",
                    color: SpaceTheme.electricBlue
                ) {
                    openDataInsight(metricInsight(for: .activeStages))
                }
            }
        }
    }

    private var realStageStackView: some View {
        Group {
            if !realStageSnapshots.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                        Text("STAGE STACK")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(spacing: 10) {
                        ForEach(realStageSnapshots) { stage in
                            Button {
                                openDataInsight(stageInsight(for: stage))
                            } label: {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(stage.statusColor)
                                        .frame(width: 8, height: 8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stage.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 8) {
                                            Text("IGN \(stage.ignition.map { "T+\(formatTime($0.time))" } ?? "TBD")")
                                            Text("SEP \(stage.separation.map { "T+\(formatTime($0.time))" } ?? "TBD")")
                                        }
                                        .font(.caption2.weight(.medium).monospacedDigit())
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer(minLength: 4)
                                    
                                    HStack(spacing: 8) {
                                        Text(stage.status.uppercased())
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(stage.statusColor)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(.secondary.opacity(0.5))
                                    }
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PressScaleButtonStyle())
                        }
                    }
                }
            }
        }
    }

    // mission timeline panel (sheet)
    private var stageInfoPanel: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // header
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundColor(SpaceTheme.electricBlue)
                        Text("MISSION DATA")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(1)
                    }
                    
                    flightDataSummaryView
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.white.opacity(0.04)).shadow(radius: 8))
                    
                    // divider
                    Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.horizontal, 4)
                    
                    realStageStackView
                    
                    // divider
                    Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1).padding(.horizontal, 4)
                    
                    // timeline events
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text("EVENTS")
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                        
                        // action buttons row
                        HStack(spacing: 12) {
                            Button {
                                isLooping.toggle()
                                showStagePanel = false
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "repeat")
                                        .font(.system(size: 16))
                                    Text("Looping")
                                        .font(.caption2.weight(.semibold))
                                }
                                .foregroundColor(isLooping ? SpaceTheme.electricBlue : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(isLooping ? SpaceTheme.electricBlue.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            
                            Button(role: .destructive) {
#if os(iOS)
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
#endif
                                currentTime = 0
                                showStagePanel = false
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 16))
                                    Text("Restart")
                                        .font(.caption2.weight(.semibold))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        
                        VStack(spacing: 10) {
                            ForEach(stageEvents) { event in
                                let isPast = event.time <= currentTime
                                let isCurrent = abs(event.time - currentTime) < 10
                                
                                Button {
                                    openDataInsight(eventInsight(for: event))
                                } label: {
                                    HStack(spacing: 12) {
                                        // timeline dot
                                        ZStack {
                                            Circle()
                                                .fill(isPast ? event.color : Color(.tertiarySystemFill))
                                                .frame(width: 10, height: 10)
                                            if isCurrent {
                                                Circle()
                                                    .strokeBorder(event.color, lineWidth: 2)
                                                    .frame(width: 18, height: 18)
                                            }
                                        }
                                        .frame(width: 18)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event.stageName)
                                                .font(.subheadline.weight(isPast ? .bold : .medium))
                                                .foregroundColor(isPast ? .primary : .secondary)
                                                .lineLimit(1)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: event.icon)
                                                    .font(.caption2)
                                                    .foregroundColor(isPast ? event.color : .secondary)
                                                Text(event.eventType.rawValue)
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundColor(isPast ? event.color : .secondary)
                                            }
                                        }
                                        
                                        Spacer(minLength: 0)
                                        
                                        HStack(spacing: 8) {
                                            Text("T+\(formatTime(event.time))")
                                                .font(.caption2.weight(.bold).monospacedDigit())
                                                .foregroundColor(isPast ? .secondary : Color(.quaternaryLabel))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption2.weight(.bold))
                                                .foregroundColor(.secondary.opacity(0.5))
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(isCurrent ? event.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isCurrent ? 1.5 : 1)
                                    )
                                    .shadow(color: isCurrent ? event.color.opacity(0.3) : .clear, radius: isCurrent ? 8 : 0)
                                }
                                .buttonStyle(PressScaleButtonStyle())
                            }
                        }
                    }
                    
                    // mission phase info at the very bottom
                    HStack(spacing: 12) {
                        Image(systemName: "location.north.fill")
                            .font(.body)
                            .foregroundColor(.cyan)
                        Text(currentPhaseDescription)
                            .font(.callout.weight(.medium))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Mission Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showStagePanel = false
                    }
                }
            }
            .navigationDestination(
                isPresented: Binding(
                    get: { showDataInsightDetail && selectedDataInsight != nil },
                    set: { active in
                        if !active {
                            showDataInsightDetail = false
                            selectedDataInsight = nil
                        }
                    }
                )
            ) {
                dataInsightDestination
            }
        }
    }
    
    private func dataTile(
        label: String,
        value: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(color)

                    Text(value)
                        .font(.title3.weight(.bold).monospacedDigit())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
    }
        
        /// real descriptions for each mission event
        private func eventDescription(for event: StageEvent) -> String {
            let name = event.stageName
            switch event.eventType {
            case .ignition:
                if name.contains("S-IC") { return "Five F-1 engines ignite, producing 7.5 million pounds of thrust" }
                if name.contains("S-II") { return "Five J-2 engines ignite for second stage powered flight" }
                if name.contains("S-IVB") { return "Single J-2 engine ignites for orbital insertion" }
                if name.contains("Falcon") { return "Nine Merlin 1D engines ignite at sea level" }
                return "Engines ignite for powered flight"
            case .separation:
                if name.contains("S-IC") { return "First stage exhausted after 2.5 min burn, falls to Atlantic Ocean" }
                if name.contains("S-II") { return "Second stage separates at 175 km after 6 min burn" }
                if name.contains("S-IVB") { return "Third stage separates after achieving parking orbit" }
                return "Stage separates from the vehicle stack"
            case .jettison:
                if name.contains("Escape") || name.contains("LES") { return "Launch escape tower no longer needed above atmosphere" }
                if name.contains("Fairing") { return "Payload fairing jettisoned, exposing payload to space" }
                if name.contains("Inboard") { return "Center engine shut down to limit acceleration to 4G" }
                return "Component jettisoned to reduce weight"
            case .deployment:
                return "Payload successfully deployed into target orbit"
            case .landing:
                return "Stage performs powered landing for recovery and reuse"
            }
        }
        
        private func metricInsight(for kind: MetricKind) -> DataInsight {
            let altitude = Double(currentPoint?.y ?? 0)
            let velocity = currentPoint?.velocity ?? 0
            let downrange = Double(currentPoint?.x ?? 0)
            let activeCount = activeStageNames.count
            let previousEvent = stageEvents.last(where: { $0.time <= currentTime })
            let nextEvent = stageEvents.first(where: { $0.time > currentTime })
            
            switch kind {
            case .altitude:
                return DataInsight(
                    title: "Altitude",
                    icon: "arrow.up.right.circle.fill",
                    highlightValue: String(format: "%.1f km", altitude),
                    summary: "Current vertical distance above sea level. This drives atmospheric pressure and heating regime during ascent.",
                    details: [
                        ("Flight Regime", altitudeRegime(for: altitude)),
                        ("Karman Line Delta", String(format: "%+.1f km vs 100 km", altitude - 100)),
                        ("Previous Major Event", previousEvent?.stageName ?? "Launch not started"),
                        ("Next Major Event", nextEvent?.stageName ?? "No pending event")
                    ],
                    accentColor: .cyan
                )
            case .velocity:
                let orbitalReference = 27_600.0
                return DataInsight(
                    title: "Velocity",
                    icon: "gauge.with.dots.needle.67percent",
                    highlightValue: String(format: "%.0f km/h", velocity),
                    summary: "Vehicle speed along the trajectory. Reaching orbital-class velocity is required for sustained Earth orbit.",
                    details: [
                        ("Vs Orbital Speed", String(format: "%.0f%% of 27,600 km/h", (velocity / orbitalReference) * 100)),
                        ("Approx Mach", String(format: "Mach %.1f (sea-level equivalent)", velocity / 1_225.0)),
                        ("Current Phase", currentPhaseDescription),
                        ("Next Event In", timeToNextEventString())
                    ],
                    accentColor: .orange
                )
            case .downrange:
                return DataInsight(
                    title: "Downrange Distance",
                    icon: "point.topleft.down.curvedto.point.bottomright.up",
                    highlightValue: String(format: "%.1f km", downrange),
                    summary: "Horizontal ground-track displacement from launch site, indicating how far the vehicle has progressed toward orbit.",
                    details: [
                        ("Current Ground Track", String(format: "%.1f km", downrange)),
                        ("Trajectory Ratio", String(format: "%.0f%% of mission profile", min(100, max(0, (currentTime / maxTime) * 100)))),
                        ("Last Event Altitude", previousEvent.map { "\(Int($0.altitude)) km" } ?? "N/A"),
                        ("Target Destination", launch.targetDestination)
                    ],
                    accentColor: .green
                )
            case .activeStages:
                return DataInsight(
                    title: "Active Stages",
                    icon: "square.stack.3d.up.fill",
                    highlightValue: "\(activeCount)",
                    summary: "Number of attached/active stages at this mission time. Stage transitions define thrust profile and mission efficiency.",
                    details: [
                        ("Attached Modules", activeStageNames.isEmpty ? "None" : activeStageNames.joined(separator: ", ")),
                        ("Separated Events", "\(separatedStages.count)"),
                        ("Stage Timeline Events", "\(stageEvents.count)"),
                        ("Mission Time", "T+\(formatTime(currentTime))")
                    ],
                    accentColor: SpaceTheme.electricBlue
                )
            }
        }
        
        private func eventInsight(for event: StageEvent) -> DataInsight {
            DataInsight(
                title: event.stageName,
                icon: event.icon,
                highlightValue: "T+\(formatTime(event.time))",
                summary: eventDescription(for: event),
                details: [
                    ("Event Type", event.eventType.rawValue),
                    ("Mission Time", "T+\(formatTime(event.time))"),
                    ("Altitude", String(format: "%.0f km", event.altitude)),
                    ("Relative To Now", event.time <= currentTime ? "Occurred \(formatTime(currentTime - event.time)) ago" : "In \(formatTime(event.time - currentTime))")
                ],
                accentColor: event.color
            )
        }
        
        private func altitudeRegime(for altitudeKm: Double) -> String {
            switch altitudeKm {
            case ..<12: return "Troposphere"
            case ..<50: return "Stratosphere"
            case ..<85: return "Mesosphere"
            case ..<700: return "Thermosphere"
            default: return "Exosphere"
            }
        }
        
        private func timeToNextEventString() -> String {
            guard let nextEvent = stageEvents.first(where: { $0.time > currentTime }) else {
                return "No pending event"
            }
            return "T+\(formatTime(nextEvent.time)) (\(formatTime(nextEvent.time - currentTime)) left)"
        }
        
        private func stageInsight(for snapshot: RealStageSnapshot) -> DataInsight {
            let stageData = RocketStageData.stages(for: launch.rocketName).first {
                stageEventMatchesStage(eventName: $0.name, stageName: snapshot.name)
            }
            
            var detailRows: [(String, String)] = [
                ("Status", snapshot.status),
                ("Ignition", snapshot.ignition.map { "T+\(formatTime($0.time))" } ?? "TBD"),
                ("Separation", snapshot.separation.map { "T+\(formatTime($0.time))" } ?? "TBD"),
                ("Mission Time", "T+\(formatTime(currentTime))")
            ]
            
            if let data = stageData {
                for spec in data.specs.prefix(4) {
                    detailRows.append((spec.0, spec.1))
                }
            }
            
            return DataInsight(
                title: snapshot.name,
                icon: "square.stack.3d.up.fill",
                highlightValue: snapshot.status,
                summary: stageData?.description ?? "Real mission stage in the vehicle stack.",
                details: detailRows,
                accentColor: snapshot.statusColor
            )
        }
        
        private func stageEventMatchesStage(eventName: String, stageName: String) -> Bool {
            let eventNorm = normalize(eventName)
            let stageNorm = normalize(stageName)
            if eventNorm.isEmpty || stageNorm.isEmpty { return false }
            if eventNorm.contains(stageNorm) || stageNorm.contains(eventNorm) { return true }
            
            let eventTokens = Set(normalizedTokens(eventName))
            let stageTokens = Set(normalizedTokens(stageName))
            return !eventTokens.isDisjoint(with: stageTokens)
        }
        
        private func normalizedTokens(_ value: String) -> [String] {
            value
                .lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty && $0.count > 2 && $0 != "and" && $0 != "stage" }
        }
        
        private func openDataInsight(_ insight: DataInsight) {
            selectedDataInsight = insight
            showDataInsightDetail = true
            if isPlaying {
                stopPlayback()
            }
        }
        
        @ViewBuilder
        private var dataInsightDestination: some View {
            if let insight = selectedDataInsight {
                DataInsightDetailView(insight: insight)
            } else {
                EmptyView()
            }
        }
        

       
        
        // the old partdetailoverlay is removed since we use partinformationview now
        
        // handle node tap
        private func handleNodeTap(nodeName: String) {
            if isPlanetNode(nodeName) {
                if isPlaying {
                    stopPlayback()
                }
                return
            }
            
            // try finding complete rocketpart data first using semantic tap aliases.
            let parts = replayRocketParts
            if !parts.isEmpty {
                for key in partSearchKeys(from: nodeName) {
                    if let matchedPart = findRocketPart(named: key, in: parts) {
                        withAnimation(.spring(response: 0.3)) {
                            tappedPartInfo = nil
                            selectedRocketPart = matchedPart
                        }
                        return
                    }
                }
            }
            
            // try apollo 11 part data first
            if let apolloPart = Apollo11PartDataProvider.matchPart(nodeName: nodeName) {
                withAnimation(.spring(response: 0.3)) {
                    selectedRocketPart = nil
                    tappedPartInfo = TappedPartInfo(
                        name: apolloPart.name,
                        icon: apolloPart.icon,
                        description: apolloPart.description,
                        specs: apolloPart.specs,
                        accentColor: apolloPart.accentColor
                    )
                }
                return
            }
            
            // try matching stage data
            let stages = RocketStageData.stages(for: launch.rocketName)
            let normalizedNodeName = normalize(nodeName)
            if let stage = stages.first(where: {
                let normalizedStageName = normalize($0.name)
                return normalizedNodeName.contains(normalizedStageName)
                || normalizedStageName.contains(normalizedNodeName)
            }) {
                withAnimation(.spring(response: 0.3)) {
                    selectedRocketPart = nil
                    tappedPartInfo = TappedPartInfo(
                        name: stage.name,
                        icon: "cylinder.fill",
                        description: stage.description,
                        specs: [
                            ("Height", "\(Int(stage.height))m"),
                            ("Engines", "\(stage.engineCount)"),
                            ("Width", String(format: "%.1f", stage.relativeWidth))
                        ],
                        accentColor: stage.bodyColor
                    )
                }
                return
            }
            
            // generic part info from node name
            let cleanName = nodeName
                .replacingOccurrences(of: "_", with: " ")
                .replacingOccurrences(of: "-", with: " ")
                .capitalized
            withAnimation(.spring(response: 0.3)) {
                selectedRocketPart = nil
                tappedPartInfo = TappedPartInfo(
                    name: cleanName,
                    icon: "cube.fill",
                    description: "Component of the \(launch.rocketName) rocket.",
                    specs: [],
                    accentColor: SpaceTheme.electricBlue
                )
            }
        }
        
        private func findRocketPart(named name: String, in parts: [RocketPart]) -> RocketPart? {
            let needle = normalize(name)
            guard !needle.isEmpty else { return nil }
            
            func search(_ list: [RocketPart]) -> RocketPart? {
                for part in list {
                    let idKey = normalize(part.id)
                    let nameKey = normalize(part.name)
                    if idKey == needle || nameKey == needle || idKey.contains(needle) || nameKey.contains(needle) || needle.contains(idKey) {
                        return part
                    }
                    if let found = search(part.subparts) {
                        return found
                    }
                }
                return nil
            }
            
            return search(parts)
        }
        
        private func partSearchKeys(from nodeName: String) -> [String] {
            var keys: [String] = [nodeName]
            
            let compact = normalize(nodeName)
            if !compact.isEmpty {
                keys.append(compact)
            }
            
            let rocket = launch.rocketName.lowercased()
            
            if rocket.contains("saturn") {
                if compact.contains("sic") || compact.contains("firststage") { keys += ["sic", "sic_f1"] }
                if compact.contains("sii") || compact.contains("secondstage") { keys += ["sii", "sii_engines"] }
                if compact.contains("sivb") || compact.contains("thirdstage") { keys += ["sivb", "sivb_j2"] }
                if compact.contains("apollo") || compact.contains("commandmodule") || compact == "cm" { keys += ["cm", "sm"] }
                if compact.contains("servicemodule") || compact == "sm" { keys += ["sm", "sm_sps"] }
                if compact.contains("les") || compact.contains("escapesystem") { keys += ["les"] }
                if compact.contains("lm") || compact.contains("lunarmodule") { keys += ["lm"] }
            }
            
            if rocket.contains("falcon") {
                if compact.contains("firststage") || compact == "s1" { keys += ["s1", "merlin9"] }
                if compact.contains("secondstage") || compact == "s2" { keys += ["s2", "mvac"] }
                if compact.contains("interstage") { keys += ["interstage"] }
                if compact.contains("engine") || compact.contains("merlin") || compact.contains("nozzle") { keys += ["merlin9", "mvac"] }
                if compact.contains("grid") { keys += ["gridfins"] }
                if compact.contains("landingleg") || compact.contains("landinglegs") { keys += ["landinglegs"] }
                if compact.contains("octaweb") { keys += ["s1_octaweb"] }
                if compact.contains("fairing") { keys += ["fairing"] }
            }
            
            if rocket.contains("lvm") {
                if compact.contains("s200") { keys += ["lvm3_s200", "s200_nozzle"] }
                if compact.contains("l110") { keys += ["lvm3_l110", "lvm3_vikas"] }
                if compact.contains("c25") || compact.contains("cryoupper") { keys += ["lvm3_c25", "lvm3_ce20"] }
                if compact.contains("fairing") || compact.contains("ogive") { keys += ["lvm3_ogive"] }
            }
            
            if rocket.contains("pslv") {
                if compact.contains("ps1") || compact.contains("firststage") { keys += ["pslv_ps1", "pslv_core", "pslv_strap"] }
                if compact.contains("ps2") || compact.contains("secondstage") { keys += ["pslv_ps2", "pslv_vikas"] }
                if compact.contains("ps3") { keys += ["pslv_ps3"] }
                if compact.contains("ps4") || compact.contains("upperstage") { keys += ["pslv_ps4", "ps4_l25"] }
                if compact.contains("fairing") { keys += ["pslv_fairing"] }
            }
            
            if rocket.contains("sls") {
                if compact.contains("corestage") || compact.contains("core") { keys += ["sls_core", "sls_rs25"] }
                if compact.contains("srb") || compact.contains("booster") { keys += ["sls_srb", "sls_srb_nozzle"] }
                if compact.contains("icps") { keys += ["sls_icps", "sls_rl10"] }
                if compact.contains("orion") { keys += ["sls_orion"] }
                if compact.contains("les") || compact.contains("abort") { keys += ["sls_les"] }
                if compact.contains("fairing") { keys += ["sls_orion"] }
            }
            
            if rocket.contains("atlas") {
                if compact.contains("ccb") || compact.contains("corebooster") { keys += ["atlas_ccb", "atlas_rd180"] }
                if compact.contains("centaur") { keys += ["atlas_centaur", "atlas_rl10"] }
                if compact.contains("srb") || compact.contains("booster") { keys += ["atlas_srb", "atlas_aj60a"] }
                if compact.contains("fairing") { keys += ["atlas_fairing"] }
            }
            
            if rocket.contains("ariane") {
                if compact.contains("epc") || compact.contains("core") { keys += ["ar5_epc", "ar5_vulcain"] }
                if compact.contains("eap") || compact.contains("booster") { keys += ["ar5_eap", "ar5_eap_nozzle"] }
                if compact.contains("esc") || compact.contains("upperstage") { keys += ["ar5_esc", "ar5_hm7b"] }
                if compact.contains("fairing") { keys += ["ar5_fairing"] }
            }
            
            if rocket.contains("h-ii") {
                if compact.contains("firststage") || compact.contains("h2afirst") { keys += ["h2a_first", "h2a_le7a"] }
                if compact.contains("secondstage") || compact.contains("h2asecond") { keys += ["h2a_second", "h2a_le5b"] }
                if compact.contains("srb") || compact.contains("booster") { keys += ["h2a_srb", "h2a_srb_nozzle"] }
                if compact.contains("fairing") { keys += ["h2a_fairing"] }
            }
            
            var seen = Set<String>()
            return keys.filter { key in
                let normalized = normalize(key)
                guard !normalized.isEmpty else { return false }
                return seen.insert(normalized).inserted
            }
        }
        
        private func normalize(_ value: String) -> String {
            value
                .lowercased()
                .replacingOccurrences(of: "[^a-z0-9]+", with: "", options: .regularExpression)
        }
        
        private func isPlanetNode(_ nodeName: String) -> Bool {
            let key = nodeName.lowercased()
            return key.hasPrefix("planet_")
            || key.contains("earth")
            || key.contains("moon")
            || key.contains("mars")
        }
        
        // playback control (cadisplaylink-based, zero delay)
        private func setupScene() {
            if sceneBuilder == nil {
                let builder = TrajectorySceneBuilder(
                    rocketName: launch.rocketName,
                    points: trajectoryPoints,
                    events: stageEvents
                )
                sceneBuilder = builder
            }
        }
        
#if os(macOS)
        private func startPlayback() {
            guard displayLink == nil else { return }
            isPlaying = true
            soundManager.start()
            
            let link = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
                DispatchQueue.main.async {
                    let dt = 1.0/60.0
                    let increment = dt * playbackSpeed * 5
                    if currentTime + increment >= maxTime {
                        if isLooping {
                            currentTime = 0
                            sceneBuilder?.reset()
                            sceneBuilder?.updateRocketPosition(at: 0)
                        } else {
                            currentTime = maxTime
                            stopPlayback()
                        }
                    } else {
                        currentTime += increment
                    }
                    sceneBuilder?.updateRocketPosition(at: currentTime)
                    if let alt = currentPoint?.y { soundManager.update(altitude: alt) }
                }
            }
            displayLink = link
        }
#else
        private func startPlayback() {
            guard displayLink == nil else { return }
            isPlaying = true
            soundManager.start()
            
            let link = CADisplayLink(target: DisplayLinkTarget { [self] dt in
                DispatchQueue.main.async {
                    let increment = dt * playbackSpeed * 5
                    if currentTime + increment >= maxTime {
                        if isLooping {
                            // loop: reset and continue
                            currentTime = 0
                            sceneBuilder?.reset()
                            sceneBuilder?.updateRocketPosition(at: 0)
                        } else {
                            currentTime = maxTime
                            stopPlayback()
                        }
                    } else {
                        currentTime += increment
                    }
                    sceneBuilder?.updateRocketPosition(at: currentTime)
                    if let alt = currentPoint?.y { soundManager.update(altitude: Double(alt)) }
                }
            }, selector: #selector(DisplayLinkTarget.tick))
            link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 60)
            link.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            displayLink = link
        }
#endif
        
        private func stopPlayback() {
            isPlaying = false
            soundManager.stop()
            displayLink?.invalidate()
            displayLink = nil
        }
        
        private func resetPlayback() {
            stopPlayback()
            currentTime = 0
            sceneBuilder?.reset()
            sceneBuilder?.updateRocketPosition(at: 0)
        }
        
        private func formatTime(_ t: Double) -> String {
            let m = Int(t) / 60
            let s = Int(t) % 60
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    private struct DataInsightDetailView: View {
        let insight: LaunchReplayView.DataInsight
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: insight.icon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(insight.accentColor)
                            Text(insight.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Text(insight.highlightValue)
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(insight.accentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(insight.accentColor.opacity(0.15), in: Capsule())
                        
                        Text(insight.summary)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.white.opacity(0.05))
                
                if !insight.details.isEmpty {
                    Section {
                        ForEach(Array(insight.details.enumerated()), id: \.offset) { _, row in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(row.0.uppercased())
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(insight.accentColor)
                                Text(row.1)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        Text("Current Metrics")
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle(insight.title)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
    
    // cadisplaylink target (avoids retain cycle)
    class DisplayLinkTarget {
        let callback: (Double) -> Void
        private var lastTimestamp: CFTimeInterval = 0
        
        init(callback: @escaping (Double) -> Void) {
            self.callback = callback
        }
        
        @objc func tick(_ link: CADisplayLink) {
            if lastTimestamp == 0 {
                lastTimestamp = link.timestamp
                return
            }
            let dt = link.timestamp - lastTimestamp
            lastTimestamp = link.timestamp
            callback(dt)
        }
    }
    
    // interactive scenekit view (tap to inspect parts)
#if os(macOS)
    struct LaunchReplay3DSceneView: NSViewRepresentable {
        let scene: SCNScene
        let onTapNode: (String) -> Void
        var onViewCreated: ((SCNView) -> Void)? = nil
        
        func makeNSView(context: Context) -> SCNView {
            let view = SCNView()
            view.scene = scene
            view.backgroundColor = .clear
            view.allowsCameraControl = true
            // disable panning — allow rotation only
            view.cameraControlConfiguration.allowsTranslation = false
            view.autoenablesDefaultLighting = true
            view.isPlaying = true // forces rendering while scrubbing
            onViewCreated?(view)
            return view
        }
        
        func updateNSView(_ nsView: SCNView, context: Context) {}
    }
#else
    struct LaunchReplay3DSceneView: UIViewRepresentable {
        let scene: SCNScene
        let onTapNode: (String) -> Void
        var onViewCreated: ((SCNView) -> Void)? = nil
        
        @MainActor
        func makeCoordinator() -> Coordinator { Coordinator(onTapNode: onTapNode) }
        
        func makeUIView(context: Context) -> SCNView {
            let view = SCNView()
            view.scene = scene
            view.backgroundColor = .clear
            view.allowsCameraControl = true
            // disable panning — allow rotation only
            view.cameraControlConfiguration.allowsTranslation = false
            view.autoenablesDefaultLighting = true
            view.antialiasingMode = .multisampling4X
            view.preferredFramesPerSecond = 60
            view.isPlaying = true // forces rendering while scrubbing
            
            let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
            context.coordinator.scnView = view
            
            onViewCreated?(view)
            
            return view
        }
        
        func updateUIView(_ view: SCNView, context: Context) {
            // scene is shared and updated externally by the builder
        }
        
        @MainActor
        class Coordinator: NSObject {
            let onTapNode: (String) -> Void
            weak var scnView: SCNView?
            
            init(onTapNode: @escaping (String) -> Void) { self.onTapNode = onTapNode; super.init() }
            
            @objc func handleTap(_ gesture: UITapGestureRecognizer) {
                guard let sv = scnView else { return }
                let loc = gesture.location(in: sv)
                
                // prioritize planet hit-testing so earth taps are reliably captured.
                let planetHits = sv.hitTest(loc, options: [
                    SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
                    SCNHitTestOption.ignoreHiddenNodes: true,
                    SCNHitTestOption.categoryBitMask: TrajectorySceneBuilder.planetCategoryMask
                ])
                if let planetHit = planetHits.first {
                    let nodeName = nearestNamedNode(from: planetHit.node)
                    if isPlanetNodeName(nodeName) {
                        highlightNode(planetHit.node)
                        DispatchQueue.main.async {
                            self.onTapNode(nodeName)
                        }
                        return
                    }
                }
                
                let hits = sv.hitTest(loc, options: [
                    SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue,
                    SCNHitTestOption.ignoreHiddenNodes: true
                ])
                
                if let first = hits.first(where: {
                    let name = $0.node.name ?? ""
                    return !name.isEmpty && name != "mainCamera" && name != "rocketParent" && name != "trajectory"
                }) {
                    var node = first.node
                    // walk up to find a meaningfully named node
                    while node.parent != nil {
                        if let nm = node.name, !nm.isEmpty, nm != "rocketParent", nm != "trajectory" { break }
                        if let p = node.parent { node = p } else { break }
                    }
                    
                    let finalName = node.name ?? first.node.name ?? "Unknown Part"
                    if !finalName.isEmpty && finalName != "mainCamera" && finalName != "rocketParent" && finalName != "trajectory" {
                        // highlight the tapped node
                        highlightNode(node)
                        DispatchQueue.main.async {
                            self.onTapNode(finalName)
                        }
                    }
                }
            }
            
            private func nearestNamedNode(from node: SCNNode) -> String {
                var current = node
                while let parent = current.parent {
                    if let name = current.name, !name.isEmpty {
                        return name
                    }
                    current = parent
                }
                return node.name ?? ""
            }
            
            private func isPlanetNodeName(_ name: String) -> Bool {
                let key = name.lowercased()
                return key.hasPrefix("planet_")
                || key.contains("earth")
                || key.contains("moon")
                || key.contains("mars")
            }
            
            private func highlightNode(_ node: SCNNode) {
                // clear previous highlights
                scnView?.scene?.rootNode.enumerateChildNodes { n, _ in
                    n.geometry?.materials.forEach { mat in
                        mat.emission.contents = UIColor.black
                    }
                }
                
                // apply glow to tapped node and children
                func apply(_ n: SCNNode) {
                    n.geometry?.materials.forEach { mat in
                        n.opacity = 1
                        mat.emission.contents = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.3)
                    }
                    n.childNodes.forEach { apply($0) }
                }
                apply(node)
            }
        }
    }
#endif

// MARK: - Launch Sound Manager

import AVFoundation

final class LaunchSoundManager: ObservableObject {
    @Published var volume: Float = 0.7 {
        didSet { updateMixer() }
    }
    @Published var isMuted: Bool = false {
        didSet { updateMixer() }
    }

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    // A low-pass filter to muffle the sound in space
    private let eqNode = AVAudioUnitEQ(numberOfBands: 1)
    
    private var isRunning = false
    private var currentAltitude: Double = 0.0

    func start() {
        guard !isRunning else { return }

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!

        engine.attach(playerNode)

        // Setup the low-pass filter
        // At launch (altitude 0), let a lot of rumble through + some high crackle (1500Hz)
        // In space (altitude > 100km), choke it down to a deep distant rumble (80Hz)
        eqNode.bands[0].filterType = .lowPass
        eqNode.bands[0].frequency = 1500
        eqNode.bands[0].bandwidth = 1.0
        eqNode.bands[0].bypass = false
        engine.attach(eqNode)

        // Connect the graph
        engine.connect(playerNode, to: eqNode, format: format)
        engine.connect(eqNode, to: engine.mainMixerNode, format: format)

        do { try engine.start() } catch { return }

        // Generate 3 seconds of "rocket roar" (pink-ish noise)
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(sampleRate * 3)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        if let data = buffer.floatChannelData?[0] {
            // Very simple pink noise approximation + low-frequency sine modulation
            var b0: Float = 0, b1: Float = 0, b2: Float = 0
            var phase: Float = 0.0
            let phaseIncr: Float = (2.0 * .pi * 25.0) / Float(sampleRate) // 25Hz throb
            
            for i in 0..<Int(frameCount) {
                let white = Float.random(in: -1.0...1.0)
                b0 = 0.99886 * b0 + white * 0.0555179
                b1 = 0.99332 * b1 + white * 0.0750759
                b2 = 0.96900 * b2 + white * 0.1538520
                let pink = b0 + b1 + b2 + white * 0.5362
                
                // Add a low-frequency throbbing effect to simulate powerful engines
                let throb = sin(phase) * 0.4 + 0.6
                phase += phaseIncr
                
                // Master scale for the buffer (prevent clipping)
                data[i] = (pink * 0.15) * throb
            }
        }

        playerNode.volume = baseMixerVolume()
        playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
        playerNode.play()

        isRunning = true
    }

    func stop() {
        playerNode.stop()
        engine.stop()
        isRunning = false
    }

    /// Dynamically update the sound based on the rocket's altitude (in km).
    /// As altitude increases, the atmosphere thins, meaning sound doesn't travel.
    /// We simulate this by lowering the low-pass cutoff and dropping the volume.
    func update(altitude: Double) {
        guard isRunning else { return }
        self.currentAltitude = max(0, altitude)
        
        let targetFreq: Float
        if altitude < 20 {
            // Lower atmosphere: loud and crackling (1500Hz down to 500Hz)
            let pct = Float(altitude / 20.0)
            targetFreq = 1500.0 - (1000.0 * pct)
        } else if altitude < 100 {
            // Upper atmosphere to Karman line: fading to a dull muffled thud (500Hz to 80Hz)
            let pct = Float((altitude - 20) / 80.0)
            targetFreq = 500.0 - (420.0 * pct)
        } else {
            // Deep space: vacuum. Only conduction through the hull is heard.
            targetFreq = 80.0
        }
        
        eqNode.bands[0].frequency = targetFreq
        updateMixer()
    }
    
    // Calculate the actual volume based on user settings AND altitude muting
    private func baseMixerVolume() -> Float {
        if isMuted { return 0.0 }
        
        // Volume fades out as atmosphere thins out (0 to 100km)
        // Space is silent, so above 100km volume is drastically reduced to represent internal hull vibration
        let altFactor: Float
        if currentAltitude < 100 {
            altFactor = 1.0 - Float(currentAltitude / 100.0)
        } else {
            altFactor = 0.05 // Tiny residual rumble in space
        }
        
        return volume * altFactor
    }

    private func updateMixer() {
        guard isRunning else { return }
        playerNode.volume = baseMixerVolume()
    }

    func toggleMute() {
        isMuted.toggle()
    }

    deinit {
        stop()
    }
}
