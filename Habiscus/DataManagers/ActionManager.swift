//
//  ActionManager.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//

import Foundation
import SwiftUI
import WidgetKit

class ActionManager: ObservableObject {
    private let moc = DataController.shared.container.viewContext
    
    @Published var actions: [Action] = []
    @Published var currentAction: Action?
    @Published var currentProgress: Progress?
    
    var incompleteActions: [Action] {
        actions.filter { $0.completed == false }
    }
    var incompleteOrderedActions: [Action] {
        incompleteActions.sorted { $0.order < $1.order }
    }
    
    func startProgressActions() {
        guard let progress = currentProgress else { return }
        guard !progress.actionsArray.isEmpty else { return }
        
        self.actions = progress.actionsArray
        self.currentAction = incompleteOrderedActions.first
    }
    
    func createProgressActions(habit: Habit, progress: Progress?, date: Date) {
        if let progress {
            currentProgress = progress
            guard progress.actionsArray.isEmpty else { return }
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
        guard let currentProgress else { return }
        if !currentProgress.isCompleted && currentProgress.checkCompleted() {
            currentProgress.isCompleted = true
        }
        if moc.hasChanges {
            try? moc.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
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
            Color.habiscusBlue
        case .emotion:
            Color.habiscusPink
        case .note:
            Color.habiscusPurple
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
