//
//  RepeatSelectionView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct DateOptions: View {
    @Binding var frequency: RepeatOptions
    @Binding var weekdays: Set<Weekday>
    @Binding var interval: Int
    @Binding var startDate: Date
    @Binding var endDate: Date?
    @State var setEndDate: Bool = false
    @State private var setInterval: Bool = false
    @State private var yearDate: Date = Date()
    
    let endDateRange: ClosedRange<Date> = {
        let start = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let end = Calendar.current.dateComponents([.year, .month, .day], from: Date.distantFuture)
        return Calendar.current.date(from: start)!...Calendar.current.date(from: end)!
    }()
    
    private var sortedWeekdaysString: String {
        let sortedDaysSelected = weekdays.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
        let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
        return daysSelectedArray.joined(separator: ", ")
    }
    private let weekdayOptions: [SelectOption<Weekday>] = Weekday.allValues.map { SelectOption($0.rawValue.localizedCapitalized, $0) }
    
    private var repeatFooter: [RepeatOptions : String] {
        return [
            .weekdays: " on weekdays",
            .weekends: " on weekends (Saturday, Sunday)"
        ]
    }
    
    private var repeatStrings: [RepeatOptions : String] {
        return [
            .daily: "day",
            .weekly: "week",
            .monthly: "month",
            .yearly: "year",
            .weekdays: "week",
            .weekends: "week"
        ]
    }
    
    var body: some View {
        Section {
            Picker(selection: $frequency.animation()) {
                ForEach(RepeatOptions.allCases) { option in
                    Text(option.rawValue.localizedCapitalized).tag(option.rawValue)
                }
            } label: {
                Label("Repeat", systemImage: "repeat")
            }
            Button {
                withAnimation {
                    setInterval.toggle()
                }
            } label: {
                HStack {
                    Label {
                        Text("Every")
                            .foregroundColor(.primary)
                    } icon: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                        
                    Spacer()
                    Text("\(interval > 1 ? String(describing: interval) : "") \(repeatStrings[frequency]!)\(interval > 1 ? "s" : "")")
                        .foregroundColor(.secondary)
                }
            }
            if setInterval {
                Picker("", selection: $interval) {
                    ForEach(1...365, id: \.self) { index in
                        Text("\(index)").tag(index)
                    }
                }
                .pickerStyle(.wheel)
            }
            if frequency == .weekly {
                MultiSelect(label: Label("On", systemImage: "calendar"),
                            selected: $weekdays,
                            options: weekdayOptions,
                            selectedOptionString: sortedWeekdaysString)
                
            }
            if frequency == .monthly {
                
            }
        } footer: {
            Text(getRepeatFooterText())
        }
        Section {
            DatePicker("Start date", selection: $startDate, displayedComponents: .date)
            NavigationLink {
                endDateSelect()
            } label: {
                HStack {
                    Text("End date")
                    Spacer()
                    if let endDate = endDate {
                        Text(endDate.formatted(date: .abbreviated, time: .omitted))
                            .foregroundColor(.secondary)
                    } else {
                        Text("None")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    func getRepeatFooterText() -> String {
        var footerText = "Habit will repeat every "
        if interval > 1 {
            footerText += String(interval) + " "
        }
        if let repeatString = repeatStrings[frequency] {
            footerText += repeatString
        }
        if interval > 1 {
            footerText += "s"
        }
        
        if let repeatText = repeatFooter[frequency] {
            footerText += repeatText
        }
        
        if frequency == .weekly {
            footerText += " on \(sortedWeekdaysString)"
        }
        if frequency == .monthly || frequency == .yearly {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd"
            footerText += " starting on \(frequency == .monthly ? formatter.string(from: startDate) : startDate.formatted(date: .long, time: .omitted))"
        }
        return footerText
    }
    
    private func endDateSelect() -> some View {
        List {
            Button {
                withAnimation {
                    setEndDate = false
                    endDate = nil
                }
            } label: {
                HStack {
                    Text("None")
                        .foregroundColor(.primary)
                    Spacer()
                    if !setEndDate {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Button {
                withAnimation {
                    setEndDate = true
                    endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
                }
            } label: {
                HStack {
                    Text("Set end date")
                        .foregroundColor(.primary)
                    Spacer()
                    if setEndDate {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            if setEndDate {
                DatePicker("End date", selection: Binding<Date>(get: {self.endDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())!}, set: { self.endDate = $0}), in: endDateRange, displayedComponents: .date)
            }
        }
        .transition(.opacity)
        .animation(.default, value: setEndDate)
    }
}

struct DateOptions_Previews: PreviewProvider {
    static var previews: some View {
        DateOptionsPreviewHelper()
    }
}

struct DateOptionsPreviewHelper: View {
    @State var frequency: RepeatOptions = .daily
    @State var weekdays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    @State var startDate = Date()
    @State var interval: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                DateOptions(frequency: $frequency, weekdays: $weekdays, interval: $interval, startDate: $startDate, endDate: .constant(nil))
            }
            .tint(.pink)
        }
    }
}
