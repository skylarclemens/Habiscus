//
//  WeekView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/15/23.
//

import SwiftUI

struct WeekView: View {
    private let weekdays: [String] = Calendar.current.weekdaySymbols
    @Binding var selectedWeekdays: Set<Weekday>
    
    var body: some View {
        HStack {
            ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                let isSelectedDay: Bool = selectedWeekdays.contains(weekday)
                VStack {
                    Text(weekday.rawValue.localizedCapitalized.prefix(1))
                        .font(.system(size: 16, design: .rounded))
                        .fontWeight(isSelectedDay ? .bold : .regular)
                }
                .foregroundColor(isSelectedDay ? .white : .primary)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(isSelectedDay ? Color.habiscusPink : Color(UIColor.systemFill))
                .opacity(isSelectedDay ? 1 : 0.75)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    if selectedWeekdays.count > 1 && selectedWeekdays.contains(weekday) {
                        selectedWeekdays.remove(weekday)
                    } else if !selectedWeekdays.contains(weekday) {
                        selectedWeekdays.insert(weekday)
                    }
                }
            }
        }
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        WeekView(selectedWeekdays: .constant([.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]))
    }
}
