//
//  IconPickerView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/8/23.
//

import SwiftUI

struct EmojiCategoryView: View {
    var emojis: [Emoji]
    var group: EmojiGroup
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 6)
    }
    @Binding var selected: String?
    @Binding var currentTab: String
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(emojis) { emoji in
                            Text(emoji.char)
                                .font(.system(size: 32))
                                .onTapGesture {
                                    selected = emoji.char
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.clear)
                                        .frame(width: 45, height: 45)
                                )
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text(group.id)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
}

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var emojiManager = EmojiManager()
    @State private var tabViewSelection = "Activities"
    @State private var originalSelectedIcon: String?
    @Binding var selectedIcon: String?
    
    init(selectedIcon: Binding<String?>) {
        self._selectedIcon = selectedIcon
        self._originalSelectedIcon = State(initialValue: selectedIcon.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if let selectedIcon = selectedIcon {
                        Text(selectedIcon)
                            .font(.largeTitle)
                    } else {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 65, height: 65)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.regularMaterial)
                )
                TabView(selection: $tabViewSelection) {
                    ForEach(emojisByGroup(emojiManager.emojis), id: \.0) { parts in
                        let group = parts.0
                        let emojis = parts.1
                        EmojiCategoryView(emojis: emojis, group: group, selected: $selectedIcon, currentTab: $tabViewSelection)
                            .tag(group.id)
                    }
                }
                .ignoresSafeArea()
                .tabViewStyle(.page(indexDisplayMode: .never))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                            selectedIcon = originalSelectedIcon
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .navigationTitle("Select icon")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func emojisByGroup(_ emojis: [Emoji]) -> [(EmojiGroup, [Emoji])] {
        let grouped = Dictionary(grouping: emojis, by: { $0.group })
        return grouped.sorted {
            $0.key.rawValue < $1.key.rawValue
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView(selectedIcon: .constant(Emoji.exampleEmoji2.char))
    }
}
