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
                    .linearGradient(colors: [Color.habiscusPink, Color.habiscusBlue], startPoint: .leading, endPoint: .trailing)
                )
            Spacer()
            VStack(spacing: -50) {
                RedactedHabitView(color: Color.habiscusPurple, goalCompletion: 0.5)
                    .scaleEffect(0.85)
                    .offset(y: 15)
                RedactedHabitView(color: Color.habiscusGreen, goalCompletion: 0.25)
                    .scaleEffect(0.90)
                    .offset(y: 10)
                RedactedHabitView(color: Color.habiscusBlue, goalCompletion: 1)
                    .scaleEffect(0.95)
                    .offset(y: 5)
                RedactedHabitView(color: Color.habiscusPink, goalCompletion: 0.75)
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
            .tint(Color.habiscusPink)
            
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
