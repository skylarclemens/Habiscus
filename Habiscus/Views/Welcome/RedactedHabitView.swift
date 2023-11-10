//
//  RedactedHabitView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/8/23.
//

import SwiftUI

struct RedactedHabitView: View {
    var color: Color
    var isSkipped: Bool = false
    var goalCompletion: Double = 0.5
    var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color)
                .shadow(color: .black.opacity(isSkipped ? 0 : 0.1), radius: 6, y: 3)
                .shadow(color: color.opacity(isSkipped ? 0 : 0.5), radius: 4, y: 3)
                .padding(.vertical, 2)
            HStack {
                Group {
                    ProgressView(value: goalCompletion > 1 ? 1.0 : goalCompletion, total: 1.0)
                        .progressViewStyle(CircleProgressStyle(color: .white, strokeWidth: 6))
                        .frame(width: size)
                    VStack(alignment: .leading) {
                        Text("Habit")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        Text("1 / 2 completed")
                            .font(.system(.callout, design: .rounded))
                            .bold()
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.leading, 8)
                }
                .redacted(reason: .placeholder)
                Spacer()
                Image(systemName: "plus")
                    .bold()
                    .foregroundColor(.white)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(0.25))
                )
            }
            .padding()
        }
        .frame(maxHeight: 80)
    }
}

#Preview {
    VStack {
        RedactedHabitView(color: Color("pink"), goalCompletion: 0.5)
        RedactedHabitView(color: Color("blue"), goalCompletion: 1)
        RedactedHabitView(color: Color("purple"), goalCompletion: 0.25)
    }
}
