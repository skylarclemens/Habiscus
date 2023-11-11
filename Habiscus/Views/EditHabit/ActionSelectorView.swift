//
//  ActionSelectorView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/10/23.
//

import SwiftUI

final class ActionSelectorModel: ObservableObject {
    @Published var actions: [Action] = []
    
    func removeAction(at offsets: IndexSet) {
        actions.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        //var movingItems: [Action] = actions.map { $0 }
        
        //print(source)
        print("Before")
        print(actions)
        actions.move(fromOffsets: source, toOffset: destination)
        
        /*if let oldIndex = source.first, oldIndex != destination {
            let newIndex = oldIndex < destination ? destination - 1 : destination
            
        }*/
        actions.enumerated().forEach { currentIndex, action in
            action.order = Int16(currentIndex)
        }
        
        print("After")
        print(actions)
    }
}

struct ActionSelectorView: View {
    @ObservedObject var actionViewModel = ActionSelectorModel()
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
                                    ActionListRowLarge(actions: $actionViewModel.actions, action: action)
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
                            if !actionViewModel.actions.isEmpty {
                                ForEach(actionViewModel.actions, id: \.self) { action in
                                    SelectedActionRow(action: action, showTimerButton: true)
                                }
                                .onDelete(perform: actionViewModel.removeAction)
                                .onMove(perform: actionViewModel.move)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.actions = self.actionViewModel.actions
                        dismiss()
                    } label: {
                        Text("Done")
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            self.actionViewModel.actions = self.actions
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

/*struct ActionListRow: View {
    @Environment(\.managedObjectContext) private var childContext
    @Binding var actions: [Action]
    let action: ActionType
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    Image(systemName: action.symbol())
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.5))
                    Text(action.label())
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .offset(x: -8)
                Spacer()
                Button {
                    withAnimation {
                        addNewAction(type: action)
                    }
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.thickMaterial)
                }
                .labelStyle(.iconOnly)
            }
            .padding(.trailing, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: 42)
            .background(action.color())
            .clipShape(.rect(cornerRadius: 10))
        }
    }
    
    func addNewAction(type: ActionType) {
        let newAction = Action(context: childContext)
        newAction.type = type.rawValue
        actions.append(newAction)
        try? childContext.save()
    }
}*/

#Preview {
    NavigationStack {
        ActionSelectorView(actions: .constant([]))
    }
}
