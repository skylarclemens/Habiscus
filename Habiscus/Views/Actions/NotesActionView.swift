//
//  NotesView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/12/23.
//

import SwiftUI

struct NotesActionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var action: Action
    var moveToNext: () -> Void
    
    @State var noteText: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Note", text: $noteText, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.tertiary, lineWidth: 1)
                    )
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        setNote(with: noteText)
                        dismiss()
                        moveToNext()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func setNote(with text: String) {
        action.completed = true
        action.text = text
        action.date = Date()
        action.progress?.habit?.lastUpdated = Date()
    }
}

#Preview {
    var emptyFunction : () -> Void = { }
    return NotesActionView(action: Action(), moveToNext: emptyFunction)
}
