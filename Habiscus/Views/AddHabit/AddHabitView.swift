//
//  AddHabit.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

enum RepeatOptions: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, yearly, weekdays, weekends
    var id: Self { self }
}

struct AddHabitView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    enum FocusedField: Hashable {
        case goalCountField
    }
    
    var habit: Habit?
    @State private var name: String = ""
    @State private var color: String = "pink"

    @State private var selectedTime = Date()
    @ObservedObject var emojiManager = EmojiManager()
    
    @State private var frequency: RepeatOptions = .daily
    @State private var interval: Int = 1
    @State private var goalCount: Int = 1
    @State private var unit: String = ""
    @State private var repeatWeeklyOn: Set<Weekday> = [Date().currentWeekday]
    private var weekdaysSelected: [RepeatOptions : Set<Weekday>] {
        return [
            .daily: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
            .weekly: repeatWeeklyOn,
            .weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            .weekends: [.saturday, .sunday],
            .monthly: [],
            .yearly: []
        ]
    }
    @State private var setReminders: Bool = true
    @State var openEmojiPicker = false
    @State var selectedEmoji: Emoji? = nil
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date? = nil
    
    @FocusState private var focusedInput: FocusedField?
    
    var body: some View {
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
                    TextField("time(s)", text: $unit)
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
                .animation(.default, value: frequency)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            .listRowSeparator(.hidden)
            
            DateOptions(frequency: $frequency, weekdays: $repeatWeeklyOn, interval: $interval, startDate: $startDate, endDate: $endDate)
            

            RemindersView(setReminders: $setReminders, selectedTime: $selectedTime)

        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // Create new Habit with managedObjectContext
                    let newHabit = Habit(context: moc)
                    let newGoal = Goal(context: moc)
                    // Sort and convert Weekday array to one string for storing/loading
                    let sortedDaysSelected = weekdaysSelected[frequency]!.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
                    let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
                    let daysSelected = daysSelectedArray.joined(separator: ", ")
                    newHabit.id = UUID()
                    newHabit.name = name
                    newHabit.color = color
                    newHabit.icon = selectedEmoji?.char
                    newHabit.createdAt = Date()
                    newHabit.startDate = startDate
                    newHabit.endDate = endDate
                    newHabit.isArchived = false
                    
                    newGoal.amount = Int16(goalCount)
                    newGoal.unit = unit.isEmpty ? "count" : unit
                    newGoal.interval = Int16(interval)
                    newGoal.frequency = frequency.rawValue
                    newGoal.weekdays = daysSelected
                    newHabit.goal = newGoal
                    
                    // Save new Habit in the context
                    try? moc.save()
                    
                    // Set reminder notifications if user sets them
                    if setReminders {
                        sortedDaysSelected.forEach { weekday in
                            NotificationManager.shared.setReminderNotification(id: newHabit.id!, on: Weekday.weekdayNums[weekday]!, at: selectedTime, body: "Time to complete \(name)", title: "Reminder")
                        }
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
    
    func calculateGoalFrequency() -> Int {
        weekdaysSelected[frequency]!.count * goalCount
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            NavigationStack {
                AddHabitView()
            }
        }
    }
}
