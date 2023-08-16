//
//  AddHabit.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI
import UserNotifications


struct CustomColorPicker: View {
    @Binding var selection: String
    let colorOptions = ["pink", "blue", "green", "purple"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { color in
                    Button {
                        selection = color
                    } label: {
                        if selection == color {
                            Circle()
                                .strokeBorder(Color(color), lineWidth: 6)
                                .frame(width: 30, height: 30)
                        } else {
                            Circle()
                                .fill(Color(color))
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

struct RemindersView: View {
    @Binding var repeatValue: String
    @Binding var selectedDateTime: Date
    @Binding var selectedDay: Weekday
    let repeatOptions = ["Once", "Daily", "Weekly", "None"]
    var body: some View {
        VStack {
            Picker("Repeat", selection: $repeatValue) {
                ForEach(repeatOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            VStack {
                if repeatValue == "Once" {
                    DatePicker("When?", selection: $selectedDateTime)
                } else if repeatValue == "Daily" {
                    DatePicker("What time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
                } else if repeatValue == "Weekly" {
                    HStack {
                        Picker("When?", selection: $selectedDay) {
                            ForEach(Weekday.allCases, id: \.self) {
                                Text($0.rawValue.localizedCapitalized).tag($0)
                            }
                        }
                        DatePicker("What day/time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                } else {
                    Text("No reminders set")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.background)
            )
        }
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .listRowInsets(EdgeInsets())
    }
}

enum Day: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
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
    
    let goalRepeatOptions = ["Daily", "Weekly"]
    @State private var goalRepeat: String = "Daily"
    @State private var goalCount: Int = 1
    @State private var metric: String = ""
    @State private var goalWeekdays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    @State var openEmojiPicker = false
    @State var selectedEmoji: Emoji? = nil
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    enum AdjustDates {
        case startDate, startEndDates
    }
    @State private var editDateSelection: AdjustDates = .startDate
    
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
                        CustomColorPicker(selection: $color)
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                    }
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .listRowInsets(EdgeInsets())
                }
                Section("Repeat goal") {
                    VStack {
                        Picker("Repeat", selection: $goalRepeat) {
                            ForEach(goalRepeatOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        VStack {
                            if goalRepeat == "Daily" {
                                WeekView(selectedWeekdays: $goalWeekdays)
                            } else {
                                Text("Goal will be reset weekly")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.background)
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
                        Text("per \(goalRepeat == "Daily" ? "day" : "week")")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .listRowBackground(Color(UIColor.systemGroupedBackground))
                    .listRowInsets(EdgeInsets())
                }
                .listRowSeparator(.hidden)
                
                Section {
                    Picker("Adjust dates", selection: $editDateSelection) {
                        Text("Start date").tag(AdjustDates.startDate)
                        Text("Start & end dates").tag(AdjustDates.startEndDates)
                    }
                    DatePicker("Start date", selection: $startDate, displayedComponents: .date)
                    if editDateSelection == .startEndDates {
                        DatePicker("End date", selection: $endDate, displayedComponents: .date)
                    }
                } header: {
                    Text("Habit dates")
                } footer: {
                    Text("Select the date you want your habit to start, and optionally select an end date")
                }
                
                Section("Reminders") {
                    RemindersView(repeatValue: $repeatValue, selectedDateTime: $selectedDateTime, selectedDay: $selectedDay)
                }
            }
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newHabit = Habit(context: moc)
                        let daysSelectedArray = goalWeekdays.map { $0.rawValue.localizedCapitalized }
                        let daysSelected = daysSelectedArray.joined(separator: ", ")
                        let endDateSelected = editDateSelection == .startEndDates ? endDate : nil
                        newHabit.id = UUID()
                        newHabit.name = name
                        newHabit.color = color
                        newHabit.icon = selectedEmoji?.char
                        newHabit.createdAt = Date.now
                        newHabit.startDate = startDate
                        newHabit.endDate = endDateSelected
                        newHabit.weekdays = daysSelected
                        newHabit.goal = Int16(goalCount)
                        newHabit.metric = metric.isEmpty ? "count" : metric
                        newHabit.isArchived = false
                        newHabit.goalFrequency = Int16(goalRepeat == "Daily" ? 1 : 7)
                        try? moc.save()
                        setReminderNotification(id: newHabit.id!)
                        
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
        goalWeekdays.count * goalCount
    }
    
    func registerLocal(center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else {return}
        }
    }
    
    func setReminderNotification(id habitId: UUID) {
        if repeatValue == "None" {
            return
        }
        
        let center = UNUserNotificationCenter.current()
        var dateComponents = DateComponents()
        if repeatValue == "Once" {
            dateComponents = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: selectedDateTime)
        } else if repeatValue == "Daily" {
            dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDateTime)
        } else if repeatValue == "Weekly" {
            dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDateTime)
            dateComponents.weekday = 1
        } else {
            return
        }
        
        registerLocal(center: center)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatValue != "Once" ? true : false)
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Time to complete \(name)!"
        
        let request = UNNotificationRequest(identifier: habitId.uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
         }
    }    
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AddHabitView()
        }
    }
}
