//
//  StatisticsView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/9/23.
//

import SwiftUI

struct StatisticsView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var habit: Habit
    
    private var currentStreak: Int {
        return habit.getCurrentStreak()
    }
    
    private var longestStreak: Int {
        return habit.getLongestStreak()
    }
    
    private var successPercentage: Int {
        return Int(habit.getSuccessPercentage() ?? 0)
    }
    
    private var columns: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 100, maximum: .infinity)), count: 3)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: sizeClass == .compact ? .leading : .center) {
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
                Text("\(successPercentage)%")
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
    static var previews: some View {
        Previewing(\.habit) { habit in
            StatisticsView(habit: habit)
        }
    }
}
