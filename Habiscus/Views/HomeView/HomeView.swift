//
//  HomeView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/21/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var dateSelected: Date
    @State private var createHabit: DataOperation<Habit>?
    
    var body: some View {
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
                        .offset(y: -15)
                }
                HabitListView(dateSelected: $dateSelected, weekdayFilter: dateSelected.currentWeekdayString)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    createHabit = DataOperation(withContext: moc)
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(item: $createHabit) { create in
            NavigationStack {
                EditHabitView(habit: create.childObject)
                    .navigationTitle("New habit")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .environment(\.managedObjectContext, create.childContext)
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

struct HomeView_Previews: PreviewProvider {
    static var dataController = DataController.shared
    
    static var previews: some View {
        NavigationStack {
            HomeView(dateSelected: .constant(Date()))
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
