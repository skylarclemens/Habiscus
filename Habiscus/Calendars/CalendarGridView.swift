//
//  CalendarGridView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/4/23.
//

import SwiftUI

struct CalendarGridView: View {
    @Binding var date: Date
    var selectedMonth: CalendarMonth
    var size: CGFloat
    var color: Color
    
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 7)
    }
    
    init(date: Binding<Date>, month: CalendarMonth, size: CGFloat, color: Color) {
        self._date = date
        self.selectedMonth = month
        self.size = size
        self.color = color
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(Calendar.shortWeekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
            }
            ForEach(1..<selectedMonth.firstWeekday, id: \.self) { space in
                Rectangle()
                    .fill(.clear)
            }
            ForEach(selectedMonth.days, id: \.id) { day in
                let dayIsToday = Calendar.current.isDate(day.date, inSameDayAs: Date())
                let dateIsSelected = Calendar.current.isDate(day.date, inSameDayAs: date)
                ZStack {
                    if dateIsSelected {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(dateIsSelected ? color : .clear)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 0)
                            .shadow(color: color.opacity(0.2), radius: 4, y: 2)
                    }
                    Text("\(day.day)")
                        .font(.system(.callout, design: .rounded))
                        .foregroundColor(dateIsSelected ? .white : (dayIsToday ? color : .primary))
                        .bold(dateIsSelected || dayIsToday)
                    Circle()
                        .fill(color)
                        .opacity(selectedMonth.calculateOpacity(for: day))
                        .frame(width: 5)
                        .position(x: size/2, y: size-3)
                    if day.skipped {
                        Circle()
                            .fill(dateIsSelected ? .clear : Color(UIColor.tertiaryLabel))
                            .frame(width: 5)
                            .position(x: size/2, y: size-3)
                    }
                }
                .frame(width: size, height: size)
                .onTapGesture {
                    date = day.date
                }
                .opacity(day.inWeekdays ? 1 : 0.33)
                .disabled(!day.inWeekdays)
            }
        }
    }
}

struct CalendarGridView_Previews: PreviewProvider {
    static var previews: some View {
        Previewing(\.habit) { habit in
            CalendarGridView(date: .constant(Date()), month: CalendarMonth(date: Date(), habit: habit), size: 36, color: Color.habiscusPink)
        }
    }
}
