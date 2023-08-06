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
                        .foregroundColor(dateIsSelected ? Color(UIColor.systemBackground) : (dayIsToday ? color : .primary))
                        .bold(dateIsSelected || dayIsToday)
                    Circle()
                        .fill(color)
                        .opacity(selectedMonth.calculateOpacity(for: day))
                        .frame(width: 5)
                        .position(x: size/2, y: size-3)
                }
                .frame(width: size, height: size)
                .onTapGesture {
                    date = day.date
                }
            }
        }
    }
}

struct CalendarGridView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        let progress = Progress(context: moc)
        let countDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        progress.id = UUID()
        progress.date = countDate
        progress.isCompleted = false
        count.id = UUID()
        count.createdAt = countDate
        count.date = Date()
        count.progress = progress
        progress.addToCounts(count)
        habit.name = "Test"
        habit.createdAt = countDate
        habit.addToProgress(progress)
        habit.goal = 2
        habit.goalFrequency = 1
        return CalendarGridView(date: .constant(Date()), month: CalendarMonth(date: Date(), habit: habit), size: 36, color: .pink)
    }
}
