//
//  ActionManager.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//

import Foundation
import SwiftUI

class ActionManager: ObservableObject {
    private let moc = DataController.shared.container.viewContext
    
    @Published var actions: [Action] = []
    @Published var currentAction: Action?
    
    var incompleteActions: [Action] {
        actions.filter { $0.completed == false }
    }
    var incompleteOrderedActions: [Action] {
        incompleteActions.sorted { $0.order < $1.order }
    }
    
    func startProgressActions(progress: Progress?) {
        guard let progress = progress else { return }
        guard !progress.actionsArray.isEmpty else { return }
        
        actions = progress.actionsArray
        currentAction = incompleteOrderedActions.first
    }
    
    func createProgressActions(habit: Habit, progress: Progress?, date: Date) {
        var currentProgress: Progress? = nil
        
        if let progress {
            guard progress.actionsArray.isEmpty else {
                self.actions = progress.actionsArray
                return
            }
            currentProgress = progress
        } else {
            let newProgress = Progress(context: moc)
            newProgress.id = UUID()
            newProgress.date = date
            newProgress.lastUpdated = Date()
            newProgress.isCompleted = false
            newProgress.habit = habit
            habit.addToProgress(newProgress)
            currentProgress = newProgress
        }
        
        habit.actionsArray.forEach { action in
            let newAction = Action(context: moc)
            newAction.type = action.type
            newAction.progress = currentProgress
            newAction.order = action.order
            newAction.number = action.number
            newAction.text = action.text
        }
        
        try? moc.save()
    }
    
    func moveToNext() {
        currentAction = incompleteOrderedActions.first
    }
}

public enum ActionType: String, CaseIterable, Identifiable {
    case timer, emotion, note
    
    public var id: Self { return self }
    
    func symbol() -> String {
        switch (self) {
        case .timer:
            "timer"
        case .emotion:
            "face.smiling"
        case .note:
            "note.text"
        }
    }
    
    func color() -> Color {
        switch (self) {
        case .timer:
            Color("blue")
        case .emotion:
            .pink
        case .note:
            Color("purple")
        }
    }
    
    func label() -> String {
        switch (self) {
        case .timer:
            "Timer"
        case .emotion:
            "Emotion rating"
        case .note:
            "Note"
        }
    }
}
