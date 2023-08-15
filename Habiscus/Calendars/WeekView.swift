//
//  WeekView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/15/23.
//

import SwiftUI

enum Weekday: String, CaseIterable {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

struct WeekView: View {
    private let weekdays: [String] = Calendar.current.weekdaySymbols
    @Binding var selectedWeekdays: [Weekday : Bool]
    
    var body: some View {
        HStack {
            ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                let isSelectedDay: Bool = selectedWeekdays[weekday] == true
                VStack {
                    Text(weekday.rawValue.localizedCapitalized.prefix(1))
                        .font(.system(size: 16, design: .rounded))
                        .fontWeight(isSelectedDay ? .bold : .regular)
                }
                .foregroundColor(isSelectedDay ? .white : .primary)
                .padding(8)
                .frame(width: 42)
                .background(isSelectedDay ? .pink : Color(UIColor.systemFill))
                .opacity(isSelectedDay ? 1 : 0.75)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    selectedWeekdays[weekday] = !selectedWeekdays[weekday]!
                }
            }
        }
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(selectedWeekdays: .constant([.sunday: true, .monday: true, .tuesday: true, .wednesday: true, .thursday: true, .friday: true, .saturday: true]))
    }
}
