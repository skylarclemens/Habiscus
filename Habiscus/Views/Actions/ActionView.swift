//
//  ActionView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/11/23.
//

import SwiftUI

struct ActionView: View {
    @ObservedObject var action: Action
    @ObservedObject var actionManager: ActionManager
    
    var body: some View {
        switch action.actionType {
        case .timer:
            TimerActionView(action: action, moveToNext: actionManager.moveToNext)
        case .emotion:
            EmotionRatingActionView(action: action, moveToNext: actionManager.moveToNext)
        case .note:
            NotesActionView(action: action, moveToNext: actionManager.moveToNext)
        }
    }
}

#Preview {
    ActionView(action: Action(), actionManager: ActionManager())
}
