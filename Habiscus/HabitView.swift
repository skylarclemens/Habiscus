//
//  HabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/23/23.
//

import SwiftUI

struct HabitView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var habit: Habit
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.quaternarySystemFill))
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.wrappedName)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text(habit.formattedCreatedDate)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        Text(habit.countsArray.count, format: .number)
                            .font(.title)
                            .foregroundColor(.primary)
                        Button {
                            simpleSuccess()
                            let newCount = Count(context: moc)
                            newCount.id = UUID()
                            newCount.count += 1
                            newCount.created_at = Date.now
                            newCount.habit = habit
                            try? moc.save()
                        } label: {
                            Image(systemName: "plus")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(habit.habitColor).opacity(0.8))
                                )
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 16)
                    .padding(.trailing, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThickMaterial)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                    .shadow(color: Color(habit.habitColor).opacity(0.3), radius: 10, y: 8)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(habit.habitColor))
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 8)
                .shadow(color: Color(habit.habitColor).opacity(0.3), radius: 10, y: 8)
                .padding()
                if habit.countsArray.count > 0 {
                    VStack(alignment: .leading) {
                        Section {
                            VStack(alignment: .leading) {
                                ForEach(habit.countsArray) { count in
                                    HStack(spacing: 12) {
                                        Text("+\(count.wrappedCount)")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(Color(habit.habitColor).opacity(0.8))
                                                    .shadow(color: Color(habit.habitColor).opacity(0.3), radius: 4, y: 2)
                                            )
                                        Text(count.createdDateString)
                                    }
                                }
                            }
                        } header: {
                            Text("Entries")
                                .font(.headline)
                                .padding(.bottom, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 8)
                    )
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationTitle(habit.wrappedName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct HabitView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        let habit = Habit(context: moc)
        let count = Count(context: moc)
        count.count += 1
        count.created_at = Date.now
        count.habit = habit
        habit.name = "Test"
        habit.created_at = Date.now
        habit.addToCounts(count)
        
        return NavigationStack {
            HabitView(habit: habit)
        }
    }
}
