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

let gridSize: CGFloat = 16

struct CountGridView: View {
    @ObservedObject var habit: Habit
    
    var allContributions: [Contribution] {
        getAllDates()
    }
    
    let rows = [
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
        GridItem(.fixed(gridSize)),
    ]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 6) {
                ForEach(allContributions) { contribution in
                    ZStack {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(.black.opacity(0.0))
                            .frame(width: 16, height: 16)
                        Rectangle()
                            .fill(.green)
                            .frame(width: gridSize, height: gridSize)
                            .opacity(calculateOpacity(from: contribution))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                }
            }
            .frame(height: 160)
        }
    }
    
    func calculateOpacity(from contribution: Contribution) -> Double {
        //print("contribution.count: \(contribution.count)")
        //print("habit goal: \(habit.goalNumber)")
        Double(contribution.count) / Double(habit.goalNumber)
    }
    
    func getAllDates() -> [Contribution] {
        let calendar = Calendar.current
        var squareArray: [Contribution] = []
        let currentYear = calendar.dateComponents([.year], from: Date()).year
        for i in (0...6).reversed() {
            let month = calendar.date(byAdding: .month, value: -i, to: Date())!
            let monthValue = calendar.dateComponents([.month], from: month).month
            let range = calendar.range(of: .day, in: .month, for: month)
            for j in range! {
                let iteratedDate = calendar.date(from: DateComponents(year: currentYear, month: monthValue, day: j))
                let progressTotalCounts = habit.progressArray.first(where: {
                    calendar.isDate($0.wrappedDate, inSameDayAs: iteratedDate!) })?.totalCount
                let contribution = Contribution(date: iteratedDate ?? Date(), count: progressTotalCounts ?? 0)
                squareArray.append(contribution)
            }
        }
        return squareArray
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
        habit.goal = 1
        habit.goalFrequency = 1
        return CountGridView(habit: habit)
    }
}
