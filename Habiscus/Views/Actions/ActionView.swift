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
    var moveToNext: (() -> Void)?
    
    
    init(action: Action, manager: ActionManager? = nil) {
        self.action = action
        self.actionManager = manager ?? ActionManager()
        if manager != nil {
            moveToNext = actionManager.moveToNext
        }
    }
    
    var body: some View {
        switch action.actionType {
        case .timer:
            TimerActionView(action: action, moveToNext: moveToNext)
                .presentationDetents([.fraction(0.5)])
        case .emotion:
            EmotionRatingActionView(action: action, moveToNext: moveToNext)
                .presentationDetents([.height(225)])
        case .note:
            NotesActionView(action: action, moveToNext: moveToNext)
                .presentationDetents([.height(350)])
        }
    }
}

#Preview {
    Previewing(\.timerAction) { action in
        VStack {
            
        }
        .sheet(isPresented: .constant(true)) {
            ActionView(action: action)
        }
        
    }
}
