//
//  RepeatSelectionView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct DateOptions: View {
    @Binding var goalRepeat: RepeatOptions
    @Binding var weekdays: Set<Weekday>
    @Binding var startDate: Date
    @Binding var endDate: Date?
    @State var setEndDate: Bool = false
    //@State var selectedEndDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    
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
            .daily: "daily",
            .weekly: "weekly",
            .weekdays: "on weekdays",
            .weekends: "on weekends (Saturday, Sunday)"
        ]
    }
    
    var body: some View {
        Section {
            Picker(selection: $goalRepeat.animation()) {
                ForEach(RepeatOptions.allCases) { option in
                    Text(option.rawValue.localizedCapitalized)
                }
            } label: {
                Label("Repeat", systemImage: "repeat")
            }
            if goalRepeat == .weekly {
                MultiSelect(label: Label("On", systemImage: "calendar"),
                            selected: $weekdays,
                            options: weekdayOptions,
                            selectedOptionString: sortedWeekdaysString)
                
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
        } footer: {
            Text("Select the date you want your habit to start, and optionally select an end date")
        }
    }
    
    func getRepeatFooterText() -> String {
        var footerText = "Habit will repeat "
        if let repeatText = repeatFooter[goalRepeat] {
            footerText += repeatText
        }
        if goalRepeat == .weekly {
            footerText += " on \(sortedWeekdaysString)"
        }
        return footerText
    }
    
    private enum SetDaysOptions: CaseIterable {
        case all, select
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
    @State var goalRepeat: RepeatOptions = .daily
    @State var weekdays: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    @State var startDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                DateOptions(goalRepeat: $goalRepeat, weekdays: $weekdays, startDate: $startDate, endDate: .constant(nil))
            }
            .tint(.pink)
        }
    }
}
