//
//  IconPickerView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/8/23.
//

import SwiftUI

let categories: [String] = ["Smileys & Emotion", "People & Body", "Food & Drink", "Travel & Places", "Activities", "Objects", "Symbols", "Flags"]

struct EmojiCategoryView: View {
    var emojis: [Emoji]
    var group: EmojiGroup
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 5)
    }
    @Binding var searchingString: String
    @Binding var selected: Emoji
    var currentTag: String
    
    private var searchResults: [Emoji] {
        if searchingString.isEmpty || currentTag != group.id {
            return emojis
        } else {
            return emojis.filter { $0.name.localizedCaseInsensitiveContains(searchingString)}
        }
    }
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: columns) {
                    ForEach(searchResults) { emoji in
                        Text(emoji.char)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.secondary.opacity(0.125))
                            )
                    }
                }
            } header: {
                Text(group.id)
            }
        }
        .frame(maxHeight: .infinity)
        .listStyle(InsetGroupedListStyle())
        .searchable(text: $searchingString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for an emoji")
    }
}

struct IconPickerView: View {
    @StateObject var emojiManager = EmojiManager()
    @State private var tabViewSelection = "Activity"
    @State private var searchingString: String = ""
    @Binding var currentIconSelected: Emoji
    
    var body: some View {
        NavigationStack {
            TabView(selection: $tabViewSelection) {
                ForEach(groupByCategory(emojiManager.emojis), id: \.0) { pair in
                    EmojiCategoryView(emojis: pair.1, group: pair.0, searchingString: $searchingString, selected: $currentIconSelected, currentTag: tabViewSelection)
                        .tag(pair.0.id)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
        }
    }
    
    func groupByCategory(_ emojis: [Emoji]) -> [(EmojiGroup, [Emoji])] {
        let grouped = Dictionary(grouping: emojis, by: { $0.group })
        return grouped.sorted {
            $0.key.rawValue < $1.key.rawValue
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        IconPickerView(currentIconSelected: .constant(Emoji.exampleEmoji))
    }
}
