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
    @State var showActionInformation: ActionType? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
                if showActionInformation != nil {
                    Rectangle().fill(.regularMaterial).ignoresSafeArea()
                        .zIndex(1)
                    ActionInfoView(information: $showActionInformation)
                        .frame(maxWidth: 300, maxHeight: 400)
                        .transition(.moveAndFade)
                        .zIndex(2)
                }
                VStack(alignment: .leading) {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(ActionType.allCases) { action in
                                    ActionListRowLarge(actions: $actions, action: action, information: $showActionInformation)
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
                        Text(action.number.formattedTimeText())
                            .font(.subheadline)
                            .foregroundStyle(.primary.opacity(0.75))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial)
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }
            }
        }
    }
}

#Preview {
    Previewing(\.newHabit) { habit in
        NavigationStack {
            ActionSelectorView(actions: .constant([]))
        }
    }
}
