//
//  AddHabit.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

enum RepeatOptions: String, CaseIterable, Identifiable {
    case daily, weekly, weekdays, weekends
    var id: Self { self }
}

struct AddHabitView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    enum FocusedField: Hashable {
        case goalCountField
    }
    
    @State private var name: String = ""
    @State private var color: String = "pink"

    @State private var repeatValue = "Daily"
    @State private var selectedDateTime = Date()
    @State private var selectedDay: Weekday = .sunday
    
    @State private var goalRepeat: RepeatOptions = .daily
    @State private var setDays: String = "all"
    @State private var goalCount: Int = 1
    @State private var metric: String = ""
    @State private var repeatWeeklyOn: Set<Weekday> = [Date().currentWeekday]
    private var weekdaysSelected: [RepeatOptions : Set<Weekday>] {
        return [
            .daily: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
            .weekly: repeatWeeklyOn,
            .weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            .weekends: [.saturday, .sunday]
        ]
    }
    @State var openEmojiPicker = false
    @State var selectedEmoji: Emoji? = nil
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    
    @FocusState private var focusedInput: FocusedField?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    VStack {
                        TextField("Meditate, Drink water, etc.", text: $name)
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
                                if let selectedEmoji = selectedEmoji {
                                    Text(selectedEmoji.char)
                                        .font(.title)
                                } else {
                                    Image(systemName: "plus")
                                        .font(.title)
                                        .foregroundColor(Color(color))
                                }
                            }
                            .frame(width: 65, height: 65)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(color).opacity(0.1))
                            )
                        }
                        ColorPickerView(selection: $color)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                    }
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .listRowInsets(EdgeInsets())
                }
                
                Section("Goal") {
                    HStack {
                        TextField("count", value: $goalCount, format: .number)
                            .keyboardType(.numberPad)
                            .focused($focusedInput, equals: .goalCountField)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .padding(4)
                            .frame(maxWidth: 100)
                        TextField("time(s)", text: $metric)
                            .textInputAutocapitalization(.never)
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .submitLabel(.done)
                        Text("per \(goalRepeat == .daily ? "day" : "week")")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .animation(.default, value: goalRepeat)
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .listRowInsets(EdgeInsets())
                }
                .listRowSeparator(.hidden)
                
                DateOptions(goalRepeat: $goalRepeat, weekdays: $repeatWeeklyOn, startDate: $startDate, endDate: $endDate)
                
                Section("Reminders") {
                    RemindersView(repeatValue: $repeatValue, selectedDateTime: $selectedDateTime, selectedDay: $selectedDay)
                }
            }
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Create new Habit with managedObjectContext
                        let newHabit = Habit(context: moc)
                        // Sort and convert Weekday array to one string for storing/loading
                        let sortedDaysSelected = weekdaysSelected[goalRepeat]!.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
                        let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
                        let daysSelected = daysSelectedArray.joined(separator: ", ")
                        newHabit.id = UUID()
                        newHabit.name = name
                        newHabit.color = color
                        newHabit.icon = selectedEmoji?.char
                        newHabit.createdAt = Date.now
                        newHabit.startDate = startDate
                        newHabit.endDate = endDate
                        newHabit.weekdays = daysSelected
                        newHabit.goal = Int16(goalCount)
                        newHabit.metric = metric.isEmpty ? "count" : metric
                        newHabit.isArchived = false
                        newHabit.goalFrequency = Int16(goalRepeat == .daily ? 1 : 7)
                        // Save new Habit in the context
                        try? moc.save()
                        // Set reminder notifications if user sets them
                        if repeatValue != "None" {
                            NotificationManager.setReminderNotification(id: newHabit.id!, repeatValue: repeatValue, on: selectedDateTime, content: UNMutableNotificationContent())
                        }
                        
                        dismiss()
                    }
                    .disabled(name.isEmpty)
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
            .tint(.pink)
            .sheet(isPresented: $openEmojiPicker) {
                IconPickerView(selectedIcon: $selectedEmoji)
                    .presentationDetents([.fraction(0.8), .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    func calculateGoalFrequency() -> Int {
        weekdaysSelected[goalRepeat]!.count * goalCount
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AddHabitView()
        }
    }
}
