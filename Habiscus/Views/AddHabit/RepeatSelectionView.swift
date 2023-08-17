//
//  RepeatSelectionView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct RepeatSelectionView: View {
    @Binding var goalRepeat: RepeatOptions
    @Binding var weekdays: Set<Weekday>
    @State private var setDays: SetDaysOptions = .all
    
    @State private var repeatFooter: [RepeatOptions : String] = [
        .daily: "daily",
        .weekly: "weekly",
        .weekdays: "on all weekdays",
        .weekends: "on weekends"
    ]
    
    var body: some View {
        Section {
            Picker(selection: $goalRepeat) {
                ForEach(RepeatOptions.allCases) { option in
                    Text(option.rawValue.localizedCapitalized)
                }
            } label: {
                Label("Repeat", systemImage: "repeat")
            }
            if goalRepeat == .daily {
                Picker(selection: $setDays) {
                    Text("All").tag(SetDaysOptions.all)
                    Text("Select").tag(SetDaysOptions.select)
                } label: {
                    Label("Days", systemImage: "calendar")
                }
            }
            if setDays == .select && goalRepeat == .daily {
                WeekView(selectedWeekdays: $weekdays)
                    .padding(.vertical, 4)
            }
        } footer: {
            Text(getRepeatFooterText())
        }
        .alignmentGuide(.listRowSeparatorLeading) { computeValue in
            return 0
        }
    }
    
    func getRepeatFooterText() -> String {
        var footerText = "Habit will repeat "
        if let repeatText = repeatFooter[goalRepeat] {
            footerText.append(repeatText)
        }
        if setDays == .select && goalRepeat == .daily {
            let daysSelectedArray = weekdays.map { $0.rawValue.localizedCapitalized }
            let daysSelected = daysSelectedArray.joined(separator: ", ")
            footerText.append(" on \(daysSelected)")
        }
        return footerText
    }
    
    private enum SetDaysOptions: CaseIterable {
        case all, select
    }
}

struct RepeatSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatSelectionView(goalRepeat: .constant(.daily), weekdays: .constant([.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]))
    }
}
