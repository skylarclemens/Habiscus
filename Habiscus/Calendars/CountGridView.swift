//
//  CountGridView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/2/23.
//

import SwiftUI

struct Contribution: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct CountGridView: View {
    @ObservedObject var habit: Habit
    var size: CGFloat = 16
    var spacing: CGFloat = 4
    
    @State private var allContributions: [Contribution] = []
    @State private var monthHeadings: [Int: Int] = [:]
    
    private var rows: [GridItem] {
        Array(repeating: .init(.fixed(size), spacing: spacing), count: 7)
    }
    
    @Namespace var rectID
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: spacing) {
                            ForEach(0 ..< allContributions.count/7 + 1, id: \.self) { index in
                                if monthHeadings[index] != nil {
                                    Rectangle()
                                        .fill(.clear)
                                        .frame(width: size, height: size)
                                        .overlay(Text(DateFormatter().shortMonthSymbols[(monthHeadings[index] ?? 1) - 1])
                                            .font(.caption.bold())
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: true, vertical: false), alignment: .leading)
                                } else {
                                    Rectangle()
                                        .fill(.clear)
                                        .frame(width: size, height: size)
                                }
                                
                            }
                        }
                        LazyHGrid(rows: rows, spacing: spacing) {
                            ForEach(allContributions) { contribution in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(.black.opacity(0.08))
                                        .frame(width: size, height: size)
                                    Rectangle()
                                        .fill(.green)
                                        .frame(width: size, height: size)
                                        .opacity(calculateOpacity(from: contribution))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                            }
                        }
                    }
                    .padding(.horizontal, size)
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        getAllDates()
                        proxy.scrollTo(rectID)
                    }
                    Rectangle()
                        .fill(.clear)
                        .opacity(0)
                        .frame(width: 0)
                        .id(rectID)
                }
            }
        }
    }
    
    func calculateOpacity(from contribution: Contribution) -> Double {
        Double(contribution.count) / Double(habit.goalNumber)
    }
    
    func getAllDates() {
        let calendar = Calendar.current
        let currentYear = calendar.dateComponents([.year], from: Date()).year
        for i in (0...5).reversed() {
            let month = calendar.date(byAdding: .month, value: -i, to: Date())!
            let monthValue = calendar.dateComponents([.month], from: month).month!
            let range = calendar.range(of: .day, in: .month, for: month)
            for j in range! {
                if j == 1 {
                    monthHeadings[allContributions.count/7] = monthValue
                }
                let iteratedDate = calendar.date(from: DateComponents(year: currentYear, month: monthValue, day: j))!
                if iteratedDate > Date() {
                    break
                }
                let progressTotalCounts = habit.progressArray.first(where: {
                    calendar.isDate($0.wrappedDate, inSameDayAs: iteratedDate) })?.totalCount
                let contribution = Contribution(date: iteratedDate, count: progressTotalCounts ?? 0)
                allContributions.append(contribution)
            }
        }
    }
}

struct CountGridView_Previews: PreviewProvider {
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
        return CountGridView(habit: habit)
    }
}
