//
//  CalendarView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/2/23.
//

import SwiftUI

extension Calendar {
    func startOfMonth(_ date: Date) -> Date {
        return self.date(from: self.dateComponents([.month, .year], from: date))!
    }
    
    func firstWeekday(_ date: Date) -> Int {
        return self.component(.weekday, from: self.startOfMonth(date))
    }
}

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    var date: Date
    var dayOfWeek: String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated))
    }
    var day: Int {
        Calendar.current.dateComponents([.day], from: date).day!
    }
    var count: Int
}

struct CalendarMonth {
    var date: Date
    var monthComponent: DateComponents {
        Calendar.current.dateComponents([.month], from: date)
    }
    var monthNum: Int {
        monthComponent.month!
    }
    var yearComponent: DateComponents {
        Calendar.current.dateComponents([.year], from: date)
    }
    var year: Int {
        yearComponent.year!
    }
    var firstWeekday: Int {
        Calendar.current.firstWeekday(date)
    }
    var dateRange: Range<Int> {
        Calendar.current.range(of: .day, in: .month, for: date)!
    }
    var days: [CalendarDay] {
        var daysArray: [CalendarDay] = []
        var day = date.startOfMonth()
        for _ in self.dateRange {
            let dayObject = CalendarDay(date: day, count: 0)
            daysArray.append(dayObject)
            day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
        }
        return daysArray
    }
}

struct CalendarView: View {
    @ObservedObject var habit: Habit
    @Binding var date: Date
    private var month: CalendarMonth = CalendarMonth(date: Date())
    var size: CGFloat
    var spacing: CGFloat
    
    private var columns: [GridItem] {
        Array(repeating: .init(.fixed(size)), count: 7)
    }
    
    private let weekdays: [String] = DateFormatter().shortWeekdaySymbols
    
    init(habit: Habit, date: Binding<Date>, size: CGFloat = 36, spacing: CGFloat = 16) {
        self.habit = habit
        self._date = date
        self.size = size
        self.spacing = spacing
        self.month = CalendarMonth(date: date.wrappedValue)
    }

    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.secondary)
                }
                ForEach(1..<month.firstWeekday, id: \.self) { space in
                    Rectangle()
                        .fill(.clear)
                }
                ForEach(month.days, id: \.self) { day in
                    let dayIsToday = Calendar.current.isDate(day.date, inSameDayAs: Date())
                    let dateIsSelected = Calendar.current.isDate(day.date, inSameDayAs: date)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(dateIsSelected ? habit.habitColor : Color(UIColor.systemBackground))
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(habit.habitColor.opacity(0.5), lineWidth: dayIsToday ? 2 : 0)
                        Text("\(day.day)")
                            .font(.callout)
                            .padding(spacing/2)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(dateIsSelected ? Color(UIColor.systemBackground) : .primary)
                            .bold(dateIsSelected)
                            .animation(.spring(), value: date)
                    }
                    .onTapGesture {
                        date = day.date
                    }
                }
            }
        }
        .padding()
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        let progress = Progress(context: moc)
        progress.id = UUID()
        progress.date = Date.now
        progress.isCompleted = false
        count.id = UUID()
        count.createdAt = Date.now
        count.date = Date.now
        count.progress = progress
        progress.addToCounts(count)
        habit.name = "Test"
        habit.createdAt = Date.now
        habit.addToProgress(progress)
        habit.goal = 2
        habit.goalFrequency = 1
        return CalendarView(habit: habit, date: .constant(Date()))
    }
}
