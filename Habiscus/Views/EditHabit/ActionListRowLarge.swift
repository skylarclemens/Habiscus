//
//  ActionListRowLarge.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/13/23.
//

import SwiftUI

struct ActionListRowLarge: View {
    @Environment(\.managedObjectContext) private var childContext
    @Binding var actions: [Action]
    let action: ActionType
    @Binding var information: ActionType?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Button {
                    withAnimation {
                        addNewAction(type: action)
                    }
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .labelStyle(.iconOnly)
                Spacer()
                /*Button {
                    withAnimation {
                        information = action
                    }
                } label: {
                    Label("Info", systemImage: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .labelStyle(.iconOnly)*/
            }
            .padding(6)
            ZStack(alignment: .bottomLeading) {
                Image(systemName: action.symbol())
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.5))
                    .offset(x: -20, y: 20)
                VStack {
                    Text(action.label())
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .clipShape(.rect(cornerRadius: 10))
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(action.color())
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .shadow(color: action.color().opacity(0.25), radius: 4, y: 2)
        )
        .frame(width: 120, height: 120)
        .padding(.top, 4)
        .padding(.bottom, 12)
    }
    
    func addNewAction(type: ActionType) {
        let newAction = Action(context: childContext)
        newAction.type = type.rawValue
        if type == .timer {
            newAction.number = 60.0
        }
        newAction.order = Int16(actions.count)
        actions.append(newAction)
        try? childContext.save()
    }
}

#Preview {
    ActionListRowLarge(actions: .constant([]), action: .timer, information: .constant(nil))
}
