//
//  WelcomeView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/8/23.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Text("Welcome to")
                .font(.system(size: 32, design: .rounded))
            Text("Habiscus")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    .linearGradient(colors: [Color("pink"), Color("blue")], startPoint: .leading, endPoint: .trailing)
                )
            Spacer()
            VStack(spacing: -50) {
                RedactedHabitView(color: Color("purple"), goalCompletion: 0.5)
                    .scaleEffect(0.85)
                    .offset(y: 15)
                RedactedHabitView(color: Color("green"), goalCompletion: 0.25)
                    .scaleEffect(0.90)
                    .offset(y: 10)
                RedactedHabitView(color: Color("blue"), goalCompletion: 1)
                    .scaleEffect(0.95)
                    .offset(y: 5)
                RedactedHabitView(color: Color("pink"), goalCompletion: 0.75)
            }
            Spacer()
            Button {
                
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color("pink"))
            
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
