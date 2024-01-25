//
//  DateRepeatView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/25/23.
//

import SwiftUI

struct DateRepeatView: View {
    @Binding var frequency: RepeatOptions
    @Binding var weekdays: Set<Weekday>
    @Binding var interval: Int16
    @State var selectedRepeatDays: IntervalOptions = .every
    
    init(frequency: Binding<RepeatOptions>, weekdays: Binding<Set<Weekday>>, interval: Binding<Int16>, weekdayOptions: [SelectOption<Weekday>]) {
        self._frequency = frequency
        self._weekdays = weekdays
        self._interval = interval
        
        if interval.wrappedValue > 1 {
            self._selectedRepeatDays = State(initialValue: .custom)
        } else if weekdays.wrappedValue.count == 7 {
            self._selectedRepeatDays = State(initialValue: .every)
        } else {
            self._selectedRepeatDays = State(initialValue: .selected)
        }
        
        self.weekdayOptions = weekdayOptions
    }
    
    enum IntervalOptions: String, CaseIterable, Identifiable {
        case every, selected, custom
        
        var id: Self { self }
    }
    
    var weekdayOptions: [SelectOption<Weekday>]
    
    var body: some View {
        VStack {
            Form {
                Picker("\(frequency == .daily ? "Repeat" : "Show") on", selection: $selectedRepeatDays) {
                    Text("Every day").tag(IntervalOptions.every)
                    Text("Selected days").tag(IntervalOptions.selected)
                    if frequency == .daily {
                        Text("Custom").tag(IntervalOptions.custom)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: selectedRepeatDays) { newSelect in
                    if newSelect == .every {
                        weekdays = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                    }
                    if newSelect != .custom {
                        interval = 1
                    }
                }
                if selectedRepeatDays == .selected {
                    MultiSelect(selected: $weekdays,
                                options: weekdayOptions)
                }
                if selectedRepeatDays == .custom {
                    Section("Repeat every") {
                        Picker("", selection: $interval) {
                            ForEach(1...365, id: \.self) { index in
                                Text("\(index) day\(index > 1 ? "s" : "")").tag(Int16(index))
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
        }
    }
}

#Preview {
    @State var frequency: RepeatOptions = .daily
    @State var selected: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    @State var interval: Int16 = 1
    let options: [SelectOption<Weekday>] = Weekday.allValues.map { SelectOption($0.rawValue.localizedCapitalized, $0) }
    return DateRepeatView(frequency: $frequency, weekdays: $selected, interval: $interval, weekdayOptions: options)
}
