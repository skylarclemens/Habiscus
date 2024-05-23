//
//  WelcomeView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/8/23.
//

import SwiftUI

struct WelcomeView: View {
    @State var showHabitViews: Bool = false
    @State var scale = 0.8
    var finish: () -> Void
    
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
                RedactedHabitView(color: Color.habiscusPurple, goalCompletion: 0)
                    .scaleEffect(showHabitViews ? 0.85 : scale)
                    .offset(y: showHabitViews ? 15 : 0)
                    .opacity(showHabitViews ? 1 : 0)
                    .animation(.spring.delay(1.2), value: showHabitViews)
                RedactedHabitView(color: Color.habiscusGreen, goalCompletion: 0.25)
                    .scaleEffect(showHabitViews ? 0.90 : scale)
                    .offset(y: showHabitViews ? 10 : 0)
                    .opacity(showHabitViews ? 1 : 0)
                    .animation(.spring.delay(0.9), value: showHabitViews)
                RedactedHabitView(color: Color.habiscusBlue, goalCompletion: 1)
                    .scaleEffect(showHabitViews ? 0.95 : scale)
                    .offset(y: showHabitViews ? 5 : 0)
                    .opacity(showHabitViews ? 1 : 0)
                    .animation(.spring.delay(0.6), value: showHabitViews)
                RedactedHabitView(color: Color.habiscusPink, goalCompletion: 0.75)
                    .scaleEffect(showHabitViews ? 1.0 : scale)
                    .opacity(showHabitViews ? 1 : 0)
                    .animation(.spring.delay(0.3), value: showHabitViews)
            }
            Spacer()
            Button {
                finish()
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
        .onAppear {
            withAnimation {
                self.showHabitViews = true
            }
            HapticManager.shared.welcomeHaptic()
        }
    }
}

#Preview {
    WelcomeView(finish: { })
}
