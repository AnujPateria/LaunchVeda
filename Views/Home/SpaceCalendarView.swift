import SwiftUI

// space calendar view
struct SpaceCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayedMonth = Date()
    @State private var selectedDate: Date? = nil
    @State private var showDatePicker = false
    
    private let calendar = Calendar.current
    
    private var allEvents: [SpaceCalendarEvent] {
        SpaceCalendarEvent.allEvents
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    
                    // month navigation
                    monthNavigation
                        .padding(.horizontal, 16)

                    // weekday headers + day grid
                    calendarGrid
                        .padding(.horizontal, 16)

                    if let sel = selectedDate {
                        selectedDayEvents(for: sel)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .navigationDestination(for: Launch.self) { launch in
                LaunchDetailView(launch: launch)
            }
            .navigationDestination(for: Mission.self) { mission in
                MissionDetailView(mission: mission)
            }
            .navigationTitle("Space Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Done")
                }
            }
            .onAppear {
                selectedDate = calendar.startOfDay(for: Date())
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    DatePicker(
                        "Select Month",
                        selection: $displayedMonth,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showDatePicker = false
                                // auto-select the 1st of the newly picked month to refresh view
                                if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) {
                                    selectedDate = startOfMonth
                                }
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    // month navigation
    private var monthNavigation: some View {
        HStack {
            // month + year (tappable to open date picker)
            Button {
                showDatePicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(monthYearString)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
            }
            .accessibilityLabel("Go to today")

            Spacer()

            // navigation arrows
            HStack(spacing: 20) {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Previous month")

                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Next month")
            }
        }
    }

    // calendar grid
    private var calendarGrid: some View {
        VStack(spacing: 8) {
            // weekday headers (s m t w t f s)
            HStack(spacing: 0) {
                ForEach(Calendar.current.veryShortStandaloneWeekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // day cells
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { day in
                    dayCell(for: day)
                }
            }
        }
    }

    // day cell
    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        if let date = date {
            let dayNumber = calendar.component(.day, from: date)
            let isSelected = isSameDay(date, selectedDate)
            let isToday = isSameDay(date, calendar.startOfDay(for: Date()))
            let dayEvents = events(for: date)
            let hasEvent = !dayEvents.isEmpty

            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    selectedDate = date
                }
            }) {
                VStack(spacing: 4) {
                    Text("\(dayNumber)")
                        .font(.body)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundColor(cellTextColor(isSelected: isSelected, isToday: isToday))
                        .frame(width: 36, height: 36)
                        .background(
                            Group {
                                if isSelected {
                                    Circle()
                                        .fill(Color.accentColor)
                                } else if isToday {
                                    Circle()
                                        .strokeBorder(Color.accentColor, lineWidth: 1.5)
                                }
                            }
                        )

                    // event dot indicators
                    if hasEvent {
                        HStack(spacing: 3) {
                            ForEach(dayEvents.prefix(3)) { event in
                                Circle()
                                    .fill(isSelected ? .white : event.color)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .frame(height: 6)
                    } else {
                        Spacer()
                            .frame(height: 6)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(minHeight: 48)
            .accessibilityLabel("\(dayNumber), \(hasEvent ? "\(dayEvents.count) events" : "no events")")
        } else {
            Color.clear
                .frame(minHeight: 48)
        }
    }

    // selected day events
    private func selectedDayEvents(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            let dayEvents = events(for: date)

            HStack {
                Text(formattedDate(date))
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if !dayEvents.isEmpty {
                    Text("\(dayEvents.count) event\(dayEvents.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)

            if dayEvents.isEmpty {
                emptyStateCard
                    .padding(.horizontal, 16)
            } else {
                ForEach(dayEvents) { event in
                    eventCard(event)
                        .padding(.horizontal, 16)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedDate)
    }

    // event card
    @ViewBuilder
    private func eventCard(_ event: SpaceCalendarEvent) -> some View {
        if let launch = event.launch {
            NavigationLink(value: launch) {
                LaunchListRow(launch: launch, now: Date())
            }
        } else if let mission = event.mission {
            NavigationLink(value: mission) {
                MissionListRow(mission: mission)
            }
        } else {
            // generic historic event card
            HStack(alignment: .top, spacing: 16) {
                // icon circle
                ZStack {
                    Circle()
                        .fill(event.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: event.icon)
                        .font(.title3)
                        .foregroundColor(event.color)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    // category
                    Text(event.category.rawValue.uppercased())
                        .font(.caption2.weight(.bold))
                        .foregroundColor(event.category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(event.category.color.opacity(0.12))
                        )

                    // title
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    // description
                    Text(event.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)

                    // year
                    Text(yearString(event.date))
                        .font(.caption.weight(.bold).monospaced())
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(white: 0.1))
            )
            .accessibilityElement(children: .combine)
        }
    }

    // empty state
    private var emptyStateCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.minus")
                .font(.largeTitle)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            Text("No events on this day")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Browse other dates to discover space milestones")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.1))
        )
    }

    // helpers
    private func cellTextColor(isSelected: Bool, isToday: Bool) -> Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }

    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
                displayedMonth = newMonth
            }
        }
    }

    private var monthYearString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: displayedMonth)
    }

    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }

    private func events(for date: Date) -> [SpaceCalendarEvent] {
        allEvents.filter { isSameDay($0.date, date) }
    }

    private func isSameDay(_ d1: Date?, _ d2: Date?) -> Bool {
        guard let d1 = d1, let d2 = d2 else { return false }
        return calendar.component(.month, from: d1) == calendar.component(.month, from: d2) &&
               calendar.component(.day, from: d1) == calendar.component(.day, from: d2) &&
               calendar.component(.year, from: d1) == calendar.component(.year, from: d2) // added year check for accuracy
    }

    private func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .long
        return fmt.string(from: date)
    }

    private func yearString(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy"
        return fmt.string(from: date)
    }
}

