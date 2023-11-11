//
//  EditHabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/18/23.
//

import SwiftUI

// TODO: Add monthly, yearly options
enum RepeatOptions: String, CaseIterable, Identifiable {
    case daily, weekly, weekdays, weekends
    
    var id: Self { self }
}

struct EditHabitView: View {
    @Environment(\.managedObjectContext) private var childContext
    @Environment(\.dismiss) private var dismiss
    
    // New object if creating, and existing object if editing
    @ObservedObject var habit: Habit
    
    @State private var openEmojiPicker: Bool = false
    @State private var openActionPicker: Bool = false
    @FocusState private var focusedInput: FocusedField?
    enum FocusedField: Hashable {
        case goalCountField
    }
    // Whether setting reminders is toggled
    @State private var setReminders: Bool = true
    // Time for reminders to be set
    @State private var selectedTime = Date()
    
    
    @State private var frequency: RepeatOptions
    @State private var weekdays: Set<Weekday>
    @State private var startDate: Date
    @State private var notifications: [Notification]
    @State var selectedEmoji: String? = nil
    private var weekdaysSelected: [RepeatOptions : Set<Weekday>] {
        return [
            .daily: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
            .weekly: weekdays,
            .weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            .weekends: [.saturday, .sunday],
        ]
    }
    @State var actions: [Action]
    @State private var progressMethod: HabitProgressMethod = .actions
    private enum HabitProgressMethod {
        case actions, counts
    }
    
    init(habit: Habit) {
        self.habit = habit
        self._frequency = State(initialValue: RepeatOptions(rawValue: habit.frequency ?? "") ?? .daily)
        self._startDate = State(initialValue: habit.startDate ?? Calendar.current.startOfDay(for: Date()))
        self._weekdays = State(initialValue: (habit.weekdays != nil) ? Set(habit.weekdaysArray) : [Date().currentWeekday])
        self._notifications = State(initialValue: habit.notificationsArray)
        self._actions = State(initialValue: habit.actionsArray)
        if let _ = habit.createdAt {
            if habit.notificationsArray.count > 0 {
                if let firstNotification = habit.notificationsArray.first {
                    self._selectedTime = State(initialValue: firstNotification.wrappedTime)
                }
            } else {
                self._setReminders = State(initialValue: false)
            }
        }
    }
    
    var body: some View {
        Form {
            Section("Name") {
                VStack {
                    TextField("Meditate, Drink water, etc.", text: $habit.name ?? "")
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .submitLabel(.done)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            Section("Icon and Color") {
                HStack(alignment: .center) {
                    Button {
                        openEmojiPicker = true
                    } label: {
                        VStack {
                            if let selectedEmoji = habit.icon {
                                Text(selectedEmoji)
                                    .font(.title)
                            } else {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(Color(habit.color ?? "pink"))
                            }
                        }
                        .frame(width: 65, height: 65)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(habit.color ?? "pink").opacity(0.1))
                        )
                    }
                    ColorPickerView(selection: $habit.color ?? "pink")
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
                
            }
            Section {
                Picker("Progress method", selection: $progressMethod) {
                    Text("Counts")
                        .tag(HabitProgressMethod.counts)
                    Text("Actions")
                        .tag(HabitProgressMethod.actions)
                }
            }
            if progressMethod == .counts {
                Section {
                    HStack {
                        TextField("count", value: $habit.goal, format: .number)
                            .keyboardType(.numberPad)
                            .focused($focusedInput, equals: .goalCountField)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .frame(maxWidth: 100)
                        TextField("time(s)", text: $habit.unit ?? "")
                            .textInputAutocapitalization(.never)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .submitLabel(.done)
                        Text("per \(frequency == .daily ? "day" : "week")")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .listRowInsets(EdgeInsets())
                } header: {
                    Text("Goal")
                } footer: {
                    Text("Adjust the default count in 'Additional options'.")
                }
                .listRowSeparator(.hidden)
            } else {
                Section {
                    if !actions.isEmpty {
                        ForEach(actions, id: \.self) { (action: Action) in
                            SelectedActionRow(action: action)
                        }
                    }
                    Button("Manage actions") {
                        openActionPicker = true
                    }
                }
            }
            DateOptions(frequency: $frequency, weekdays: $weekdays, interval: $habit.interval, startDate: $startDate, endDate: $habit.endDate)
            
            RemindersView(setReminders: $setReminders, selectedTime: $selectedTime, notifications: $notifications)
            if progressMethod == .counts {
                NavigationLink {
                    AdditionalOptionsView(isCustomCount: $habit.customCount, defaultCount: $habit.defaultCount)
                } label: {
                    Text("Additional options")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Sort selected week days
                    let sortedDaysSelected = weekdaysSelected[frequency]!.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
                    let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
                    // Convert to string array for storage
                    let daysSelected = daysSelectedArray.joined(separator: ", ")
                    if habit.createdAt == nil {
                        habit.id = UUID()
                        habit.createdAt = Date()
                        habit.isArchived = false
                    }
                    habit.weekdays = daysSelected
                    habit.frequency = frequency.rawValue
                    habit.startDate = startDate
                    if progressMethod == .actions {
                        actions.forEach { action in
                            action.habit = habit
                        }
                    }
                    
                    // Remove all current notifications
                    let habitManager = HabitManager(habit: habit)
                    habitManager.removeAllNotifications()
                    // Create new notifications if toggle is set
                    if setReminders {
                        sortedDaysSelected.forEach { weekday in
                            NotificationManager.shared.setReminderNotification(for: habit, in: childContext, on: Weekday.weekdayNums[weekday]!, at: selectedTime, body: "Time to complete \(habit.name ?? "habit")", title: "Reminder")
                        }
                    }
                    
                    // Save new/edited Habit in the child context
                    try? childContext.save()
                    // Save in the parent context
                    if let parentContext = childContext.parent {
                        try? parentContext.save()
                    }
                    dismiss()
                }
                .disabled((habit.name ?? "").isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                if focusedInput == .goalCountField {
                    Spacer()
                    Button("Done") {
                        focusedInput = nil
                    }
                }
            }
        }
        .sheet(isPresented: $openEmojiPicker) {
            IconPickerView(selectedIcon: $habit.icon)
                .presentationDetents([.fraction(0.8), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $openActionPicker) {
            ActionSelectorView(actions: $actions)
        }
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct EditHabitView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.newHabit) { habit in
            ZStack {
                NavigationStack {
                    EditHabitView(habit: habit)
                }
            }
        }
    }
}
