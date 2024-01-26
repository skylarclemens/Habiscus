//
//  NotesView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/12/23.
//

import SwiftUI

struct NotesActionView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var action: Action
    var moveToNext: (() -> Void)? = nil
    
    @FocusState private var focusedInput: FocusedField?
    enum FocusedField: Hashable {
        case note
    }
    
    @State var noteText: String = ""
    
    init(action: Action, moveToNext: (() -> Void)? = nil, focusedInput: FocusedField? = nil) {
        self.action = action
        self.moveToNext = moveToNext
        self.focusedInput = focusedInput
        if action.completed {
            self._noteText = State(initialValue: action.text ?? "")
        } else {
            self._noteText = State(initialValue: "")
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Write your note here", text: $noteText, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .focused($focusedInput, equals: .note)
                    .disabled(action.completed)
                HStack {
                    if !action.completed {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    Button {
                        setNote(with: noteText)
                        dismiss()
                        moveToNext?()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                if action.completed {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            deleteNote()
                            dismiss()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !action.completed { focusedInput = .note }
            }
        }
    }
    
    func setNote(with text: String) {
        action.completed = true
        action.text = text
        action.date = Date()
        action.progress?.habit?.lastUpdated = Date()
    }
    
    func deleteNote() {
        let habitManager = HabitManager()
        habitManager.undoAction(action: action)
    }
}

#Preview {
    return VStack {
        
    }
    .sheet(isPresented: .constant(true)) {
        NotesActionView(action: Action())
            .presentationDetents([.height(400)])
    }
}
