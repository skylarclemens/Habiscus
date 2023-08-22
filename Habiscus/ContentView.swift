//
//  ContentView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI
import UserNotifications
import CoreHaptics

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.colorScheme) var colorScheme
    @State private var dateSelected: Date = Date()
    
    var body: some View {
        NavigationStack {
            HomeView(dateSelected: $dateSelected)
        }
        .tint(.pink)
        .onAppear {
            HapticManager.shared.prepareHaptics()
        }
        .colorSchemeStyle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.shared
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
