//
//  NoHabitsView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 2/5/24.
//

import SwiftUI

struct NoHabitsView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(spacing: 4) {
            Text("No habits for \(date.formatted(date: .abbreviated, time: .omitted))")
                .font(.title2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    NoHabitsView(date: .constant(Date()))
}
