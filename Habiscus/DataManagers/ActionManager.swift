//
//  ActionManager.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//

import Foundation
import SwiftUI

struct ActionManager {
    private let moc = DataController.shared.container.viewContext
    private let managedAction: Action?
    
    init() {
        self.managedAction = nil
    }
    
    init(action: Action) {
        self.managedAction = action
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
