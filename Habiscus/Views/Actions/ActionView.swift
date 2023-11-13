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
            TimerActionView(action: action, actionManager: actionManager)
                .presentationDetents([.fraction(0.5)])
        case .emotion:
            EmotionRatingActionView(action: action, moveToNext: actionManager.moveToNext)
                .presentationDetents([.height(200)])
        case .note:
            NotesActionView(action: action, moveToNext: actionManager.moveToNext)
                .presentationDetents([.height(350)])
        }
    }
}

#Preview {
    Previewing(\.timerAction) { action in
        VStack {
            
        }
        .sheet(isPresented: .constant(true)) {
            ActionView(action: action, actionManager: ActionManager())
        }
        
    }
}
