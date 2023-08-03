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
    
    static let shortWeekdaySymbols = Calendar.current.shortWeekdaySymbols
}

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    var dayOfWeek: String {
        date.formatted(Date.FormatStyle().weekday(.abbreviated))
    }
    var day: Int {
        Calendar.current.dateComponents([.day], from: date).day!
    }
    var count: Int
}

struct CalendarMonth: Equatable {
    let date: Date
    let habit: Habit?
    var monthComponent: DateComponents {
        Calendar.current.dateComponents([.month], from: date)
    }
    var monthString: String {
        date.formatted(Date.FormatStyle().month(.wide))
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
            var progressTotalCounts = 0
            if let habit = habit {
                progressTotalCounts = habit.progressArray.first(where: {
                    Calendar.current.isDate($0.wrappedDate, inSameDayAs: day) })?.totalCount ?? 0
            }
            let dayObject = CalendarDay(date: day, count: progressTotalCounts)
            daysArray.append(dayObject)
            day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
        }
        return daysArray
    }
    
    func calculateOpacity(for day: CalendarDay) -> Double {
        guard let habit = habit else { return 0.0 }
        return Double(day.count) / Double(habit.goalNumber)
    }
    
    static func ==(lhs: CalendarMonth, rhs: CalendarMonth) -> Bool {
        lhs.monthNum == rhs.monthNum
    }
}

struct CalendarView: View {
    @ObservedObject var habit: Habit
    @Binding var date: Date
    var size: CGFloat
    var spacing: CGFloat
    var color: Color
    
    @State private var selectedMonth: CalendarMonth
    
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 7)
    }
    
    init(habit: Habit, date: Binding<Date>, size: CGFloat = 36, spacing: CGFloat = 16, color: Color = .pink) {
        self.habit = habit
        self._date = date
        self.size = size
        self.spacing = spacing
        self.color = color
        self._selectedMonth = .init(initialValue: CalendarMonth(date: date.wrappedValue, habit: habit))
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.easeInOut) {
                        showPreviousMonth()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(color)
                }
                .accessibilityLabel(Text("Back one month"))
                .padding(.horizontal, 10)
                VStack {
                    Text(selectedMonth.monthString)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                    Text(String(selectedMonth.year))
                        .font(.system(.caption, design: .rounded))
                        .bold()
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    date = Date()
                    selectedMonth = CalendarMonth(date: date, habit: habit)
                }
                Button {
                    withAnimation(.easeInOut) {
                        showNextMonth()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(color)
                }
                .accessibilityLabel(Text("Forward one month"))
                .padding(.horizontal, 10)
            }
            .padding(.bottom)
            
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
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(dateIsSelected ? color : .clear)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, y: 0)
                            .shadow(color: color.opacity(0.2), radius: 4, y: 2)
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
        .padding()
        .gesture(
            DragGesture().onEnded { gesture in
                withAnimation(.easeInOut) {
                    if gesture.translation.width > 0 {
                        showPreviousMonth()
                    } else {
                        showNextMonth()
                    }
                }
            }
        )
    }
    
    private func showPreviousMonth() {
        let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth.date)!
        selectedMonth = CalendarMonth(date: prevMonthDate, habit: habit)
    }

    private func showNextMonth() {
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth.date)!
        selectedMonth = CalendarMonth(date: nextMonthDate, habit: habit)
    }
}

struct CalendarView_Previews: PreviewProvider {
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
        return CalendarView(habit: habit, date: .constant(Date()))
    }
}
