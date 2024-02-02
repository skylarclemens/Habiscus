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
    @Binding var interval: Int16
    @Binding var startDate: Date
    @Binding var endDate: Date?
    @State var setEndDate: Bool = false
    @State private var yearDate: Date = Date()
    
    let endDateRange: ClosedRange<Date> = {
        let start = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let end = Calendar.current.dateComponents([.year, .month, .day], from: Date.distantFuture)
        return Calendar.current.date(from: start)!...Calendar.current.date(from: end)!
    }()
    
    private var sortedWeekdaysString: String {
        if interval > 1 {
            return "every \(interval) days"
        }
        if weekdays.count == 7 {
            return "every day"
        }
        let sortedDaysSelected = weekdays.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
        let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
        return daysSelectedArray.joined(separator: ", ")
    }
    private let weekdayOptions: [SelectOption<Weekday>] = Weekday.allValues.map { SelectOption($0.rawValue.localizedCapitalized, $0) }
    
    private var repeatStrings: [RepeatOptions : String] {
        return [
            .daily: "day",
            .weekly: "week",
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
            .onChange(of: frequency) { newValue in
                weekdays = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                interval = 1
            }
            
            NavigationLink {
                DateRepeatView(frequency: $frequency, weekdays: $weekdays, interval: $interval, weekdayOptions: weekdayOptions)
            } label: {
                HStack {
                    Label("On", systemImage: "calendar")
                    Spacer()
                    Text(sortedWeekdaysString)
                        .padding(.leading)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.secondary)
                }
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
        var footerText = "Habit will repeat "
        
        if frequency == .weekly {
            footerText += "weekly and will be displayed "
        }
        
        footerText = footerText + "\(weekdays.count < 7 ? "every " : "")" + sortedWeekdaysString
        
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
    @State var interval: Int16 = 1
    
    var body: some View {
        NavigationStack {
            Form {
                DateOptions(frequency: $frequency, weekdays: $weekdays, interval: $interval, startDate: $startDate, endDate: .constant(nil))
            }
            .tint(Color.habiscusPink)
        }
    }
}
