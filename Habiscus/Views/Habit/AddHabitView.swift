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
    @Binding var selectedDay: Day
    let repeatOptions = ["Once", "Daily", "Weekly", "None"]
    var body: some View {
        VStack {
            Picker("Repeat", selection: $repeatValue) {
                ForEach(repeatOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            if repeatValue == "Once" {
                DatePicker("When?", selection: $selectedDateTime)
            } else if repeatValue == "Daily" {
                DatePicker("What time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
            } else if repeatValue == "Weekly" {
                HStack {
                    Picker("When?", selection: $selectedDay) {
                        ForEach(Day.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    DatePicker("What day/time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
        }
    }
}

enum Day: String, CaseIterable {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

struct AddHabitView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var color: String = "pink"

    @State private var repeatValue = "Daily"
    @State private var selectedDateTime = Date.now
    @State private var selectedDay: Day = .Monday
    
    let goalRepeatOptions = ["Daily", "Weekly"]
    @State private var goalRepeat: String = "Daily"
    @State private var goalCount: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name your habit") {
                    TextField("Meditate, Drink water, etc.", text: $name)
                }
                Section("Color") {
                    CustomColorPicker(selection: $color)
                }
                .listRowInsets(EdgeInsets())
                Section("Goal") {
                    VStack {
                        Picker("Repeat", selection: $goalRepeat) {
                            ForEach(goalRepeatOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(.segmented)
                        Stepper("\(goalCount) \(goalCount > 1 ? "times" : "time")", value: $goalCount, in: 1...1000)
                    }
                    
                }
                Section("Reminders") {
                    RemindersView(repeatValue: $repeatValue, selectedDateTime: $selectedDateTime, selectedDay: $selectedDay)
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newHabit = Habit(context: moc)
                        newHabit.id = UUID()
                        newHabit.name = name
                        newHabit.color = color
                        newHabit.createdAt = Date.now
                        newHabit.goal = Int16(goalCount)
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
            }
            .tint(.pink)
        }
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
        AddHabitView()
    }
}
