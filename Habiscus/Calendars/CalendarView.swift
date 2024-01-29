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
    var skipped: Bool = false
    var inWeekdays: Bool = true
}

struct CalendarMonth: Equatable, Hashable {
    let id = UUID()
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
    var isCurrentMonth: Bool {
        Calendar.current.dateComponents([.month, .year], from: date) == Calendar.current.dateComponents([.month, .year], from: Date())
    }
    var dateRange: Range<Int> {
        Calendar.current.range(of: .day, in: .month, for: date)!
    }
    var days: [CalendarDay] {
        var daysArray: [CalendarDay] = []
        var day = date.startOfMonth()
        for _ in self.dateRange {
            var progressTotalCounts = 0
            var progressIsSkipped = false
            var inWeekdays = true
            if let habit = habit {
                let currentProgress = habit.progressArray.first(where: {
                    Calendar.current.isDate($0.wrappedDate, inSameDayAs: day) })
                progressTotalCounts = currentProgress?.totalCount ?? 0
                progressIsSkipped = currentProgress?.isSkipped ?? false
                inWeekdays = habit.weekdaysArray.contains(day.currentWeekday)
            }
            let dayObject = CalendarDay(date: day, count: progressTotalCounts, skipped: progressIsSkipped, inWeekdays: inWeekdays)
            daysArray.append(dayObject)
            day = Calendar.current.date(byAdding: .day, value: 1, to: day)!
        }
        return daysArray
    }
    
    func calculateOpacity(for day: CalendarDay) -> Double {
        guard let habit = habit else { return 0.0 }
        if habit.wrappedType == .quit {
            return Double(day.count) / Double(habit.goalNumber + 1)
        }
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
    
    @State var selectedMonth: CalendarMonth
    
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
                    showPreviousMonth()
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
                    showNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(!selectedMonth.isCurrentMonth ? color : .secondary)
                }
                .accessibilityLabel(Text("Forward one month"))
                .padding(.horizontal, 10)
                .opacity(selectedMonth.isCurrentMonth ? 0.5 : 1)
                .disabled(selectedMonth.isCurrentMonth)
            }
            .padding(.bottom)
            CalendarGridView(date: $date, month: selectedMonth, size: size, color: color)
        }
        .padding()
        .gesture(
            DragGesture().onEnded { gesture in
                if gesture.translation.width > 0 {
                    showPreviousMonth()
                } else {
                    showNextMonth()
                }
            }
        )
    }
    
    private func showPreviousMonth() {
        let prevMonthDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth.date)!
        withAnimation {
            selectedMonth = CalendarMonth(date: prevMonthDate, habit: habit)
        }
    }

    private func showNextMonth() {
        let nextMonthDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth.date)!
        withAnimation {
            selectedMonth = CalendarMonth(date: nextMonthDate, habit: habit)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        Previewing(\.habit) { habit in
            CalendarView(habit: habit, date: .constant(Date()))
        }
    }
}
