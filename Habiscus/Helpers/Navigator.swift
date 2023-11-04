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
}
