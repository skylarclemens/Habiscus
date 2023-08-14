//
//  EmojiManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/8/23.
//

import Foundation

struct Emoji: Codable, Hashable, Identifiable {
    var id: String { codes }
    let codes: String
    let char: String
    let name: String
    let category: String
    let group: EmojiGroup
    let subgroup: String
    
    static var exampleEmoji = Emoji(codes:"1F600", char:"😀", name:"grinning face", category:"Smileys & Emotion (face-smiling)", group: .smileys, subgroup:"face-smiling")
    static var exampleEmoji2 = Emoji(codes:"1F383", char:"🎃", name: "jack-o-lantern", category: "Activities (event)", group: .activities, subgroup: "event")
}

enum EmojiGroup: String, CaseIterable, Codable, Identifiable {
    var id: String { rawValue }
    case smileys = "Smileys & Emotion"
    case people = "People & Body"
    case animals = "Animals & Nature"
    case food = "Food & Drink"
    case travel = "Travel & Places"
    case activities = "Activities"
    case objects = "Objects"
    case symbols = "Symbols"
    case flags = "Flags"
}

//JSON from: https://unpkg.com/emoji.json@15.0.0/emoji.json
class EmojiManager: ObservableObject {
    @Published var emojis: [Emoji] = []
    
    init() {
        self.emojis = Bundle.main.decode("emoji.json")
    }
}
