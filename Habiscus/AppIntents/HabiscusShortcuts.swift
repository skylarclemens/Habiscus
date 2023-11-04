//
//  HabiscusShortcuts.swift
//  HabiscusAppIntents
//
//  Created by Skylar Clemens on 8/23/23.
//

import AppIntents

struct HabiscusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: CompleteHabit(),
                phrases: [
                    "Complete habit in \(.applicationName)"
                ])
        AppShortcut(intent: OpenHabit(),
                    phrases: ["Open habit in \(.applicationName)"])
    }
}

