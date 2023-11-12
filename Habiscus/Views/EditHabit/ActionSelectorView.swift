//
//  ActionSelectorView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//

import SwiftUI

struct ActionSelectorView: View {
    @Environment(\.managedObjectContext) private var childContext
    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = EditMode.active
    @Binding var actions: [Action]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(ActionType.allCases) { action in
                                    ActionListRowLarge(actions: $actions, action: action)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.never)
                        Text("Actions")
                            .font(.headline)
                            .padding(.leading, 24)
                            .zIndex(1)
                        List {
                            if !actions.isEmpty {
                                ForEach(actions, id: \.self) { action in
                                    SelectedActionRow(action: action, showTimerButton: true)
                                }
                                .onDelete(perform: removeAction)
                                .onMove(perform: move)
                            } else {
                                Text("No actions added")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .environment(\.editMode, $editMode)
                        .offset(y: -30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func removeAction(at offsets: IndexSet) {
        for index in offsets {
            let action = actions[index]
            childContext.delete(action)
            actions.remove(atOffsets: offsets)
        }
        setActionOrder()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        actions.move(fromOffsets: source, toOffset: destination)
        setActionOrder()
    }
    
    func setActionOrder() {
        actions.enumerated().forEach { currentIndex, action in
            action.order = Int16(currentIndex)
        }
    }
}

struct SelectedActionRow: View {
    @ObservedObject var action: Action
    
    @State var showTimerButton: Bool = false
    var body: some View {
        VStack {
            HStack {
                Image(systemName: action.actionType.symbol())
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                Text(action.actionType.label())
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                if action.actionType == .timer {
                    if showTimerButton {
                        TimePickerWheel(time: action.timerHoursAndMintutes, timerNumber: $action.number)
                    } else {
                        Text("\(action.timerHoursAndMintutes.hours) hr, \(action.timerHoursAndMintutes.minutes) min")
                    }
                }
            }
        }
    }
}

struct ActionListRowLarge: View {
    @Environment(\.managedObjectContext) private var childContext
    @Binding var actions: [Action]
    let action: ActionType
    
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
                Button {
                    
                } label: {
                    Label("Add", systemImage: "info.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.75))
                }
                .labelStyle(.iconOnly)
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
            newAction.number = 1.0
        }
        newAction.order = Int16(actions.count)
        actions.append(newAction)
        try? childContext.save()
    }
}

#Preview {
    Previewing(\.newHabit) { habit in
        NavigationStack {
            ActionSelectorView(actions: .constant([]))
        }
    }
}
