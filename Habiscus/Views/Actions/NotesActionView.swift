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
    
    @FocusState private var focusedInput: FocusedField?
    enum FocusedField: Hashable {
        case note
    }
    
    @State var noteText: String = ""
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Note", text: $noteText, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.quaternary, lineWidth: 1)
                            )
                    )
                    .focused($focusedInput, equals: .note)
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    Button {
                        setNote(with: noteText)
                        dismiss()
                        moveToNext()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.vertical, 8)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                focusedInput = .note
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
