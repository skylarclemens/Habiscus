//
//  EmojiRatingView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/11/23.
//

import SwiftUI

struct EmotionRatingActionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var action: Action
    let emojis = ["😁", "😊", "😐", "😟", "😡"]
    @State var selectedEmotion: String = ""
    var moveToNext: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("How are you feeling?")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                HStack(spacing: 8) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            selectedEmotion = emoji
                            //
                        } label: {
                            Text(emoji)
                                .font(.system(size: 32))
                        }
                        .padding(10)
                        .background(
                            selectedEmotion == emoji ?
                            Color.blue.opacity(0.15) :
                                Color(UIColor.secondarySystemGroupedBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.blue.opacity(0.75), lineWidth: selectedEmotion == emoji ? 3 : 0)
                        )
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
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
                        setEmotionActionRating(with: selectedEmotion)
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
        }
    }
    
    func setEmotionActionRating(with selected: String) {
        action.completed = true
        action.text = selected
        action.date = Date()
        action.progress?.habit?.lastUpdated = Date()
    }
}

#Preview {
    var emptyFunction : () -> Void = {  }
    return EmotionRatingActionView(action: Action(), moveToNext: emptyFunction)
}
