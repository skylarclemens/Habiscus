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
    
    @State private var addHabitOpen = false
    @State private var dateSelected: Date = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .ignoresSafeArea()
                VStack {
                    VStack {
                        VStack(spacing: 0) {
                            Text(checkCloseDate().uppercased())
                                .font(.subheadline)
                                .frame(height: 16)
                            Text(dateSelected, format: .dateTime.month().day())
                                .font(.system(size: 40, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        }
                        .onTapGesture {
                            dateSelected = Date()
                        }
                        .animation(.spring(), value: dateSelected)
                        MultiWeekView(selectedDate: $dateSelected)
                            .frame(height: 60)
                            .padding(.bottom, 16)
                            .offset(y: -15)
                    }
                    HabitListView(dateSelected: $dateSelected, addHabitOpen: $addHabitOpen, weekdayFilter: dateSelected.currentWeekdayString)
                }
                .toolbar {
                    Button {
                        addHabitOpen = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
                .sheet(isPresented: $addHabitOpen) {
                    AddHabitView()
                }
            }
        }
        .tint(.pink)
        .onAppear {
            HapticManager.instance.prepareHaptics()
        }
    }
    
    func checkCloseDate() -> String {
        if Calendar.current.isDateInToday(dateSelected) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(dateSelected) {
            return "Yesterday"
        } else if Calendar.current.isDateInTomorrow(dateSelected) {
            return "Tomorrow"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: dateSelected)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var hapticManager = HapticManager()
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
