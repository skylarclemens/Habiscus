//
//  StatisticsView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/9/23.
//

import SwiftUI

struct StatisticsView: View {
    var habit: Habit
    
    private var currentStreak: Int {
        return habit.getCurrentStreak()
    }
    
    private var longestStreak: Int {
        return habit.getLongestStreak()
    }
    
    private var columns: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 100, maximum: .infinity)), count: 3)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading) {
            VStack(alignment: .leading) {
                Text("Longest streak")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                Text("\(longestStreak) \(longestStreak == 1 ? "day" : "days")")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(habit.habitColor)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
            }
            
            
            VStack(alignment: .leading) {
                Text("Current streak")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                Text("\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(habit.habitColor)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
            }
            
            
            VStack(alignment: .leading) {
                Text("Success %")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.primary.opacity(0.8))
                
                Text("\(Int(habit.successPercentage))%")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(habit.habitColor)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
            }
            
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        let progress = Progress(context: moc)
        progress.id = UUID()
        progress.date = Date.now
        progress.isCompleted = true
        count.id = UUID()
        count.createdAt = Date.now
        count.date = Date.now
        //count.progress = progress
        //progress.addToCounts(count)
        progress.isSkipped = false
        habit.name = "Test"
        habit.icon = "🤩"
        habit.createdAt = Date.now
        habit.addToProgress(progress)
        habit.goal = 1
        habit.goalFrequency = 1
        return StatisticsView(habit: habit)
    }
}
