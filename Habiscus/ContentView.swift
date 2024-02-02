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
    @StateObject var toastManager = ToastManager.shared
    @StateObject var navigator = Navigator.shared
    
    @State private var dateSelected: Date = Date()
    
    var body: some View {
        NavigationStack(path: $navigator.path) {
            HomeView(dateSelected: $dateSelected)
        }
        .tint(Color.habiscusPink)
        .onAppear {
            HapticManager.shared.prepareHaptics()
        }
        .colorSchemeStyle()
        .toast(isPresenting: $toastManager.showAlert) {
            ActionAlertView(isSuccess: $toastManager.isSuccess, successTitle: toastManager.successTitle, errorMessage: toastManager.errorMessage)
        }
        .onOpenURL { url in
            navigator.handleIncomingURL(url)
        }
        .environmentObject(toastManager)
        .environmentObject(navigator)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController.shared
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(ToastManager())
            .environmentObject(Navigator())
    }
}
