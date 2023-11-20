//
//  ViewModel.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/24/23.
//

import Foundation

class Navigator: ObservableObject {
    static var shared = Navigator()
    
    @Published var path: [Habit] = []
    
    func goTo(habit: Habit) {
        path = [habit]
    }
    
    func goHome(habit: Habit) {
        path = []
    }
    
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "habiscus" else {
            return
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        guard let action = components.host, action == "open-habit" else {
            print("Unknown URL")
            return
        }
        guard let habitId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            print("Habit ID not found")
            return
        }
        guard let habit = try? HabitsManager.shared.findHabit(id: UUID(uuidString: habitId)!) else {
            print("Cannot fetch habit")
            return
        }
        self.goTo(habit: habit)
    }
}
