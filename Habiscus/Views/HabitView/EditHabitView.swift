//
//  EditHabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/18/23.
//

import SwiftUI

struct EditHabitView: View {
    @ObservedObject var habit: Habit
    
    enum FocusedField: Hashable {
        case goalCountField
    }
    
    @FocusState private var focusedInput: FocusedField?
    
    var body: some View {
        Form {
            Section("Name") {
                VStack {
                    TextField("Meditate, Drink water, etc.", text: $habit.name ?? "")
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .submitLabel(.done)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            Section("Icon and Color") {
                HStack(alignment: .center) {
                    ColorPickerView(selection: $habit.color ?? "blue")
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            Section("Goal") {
                HStack {
                    /*TextField("count", value: $habit.goal, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedInput, equals: .goalCountField)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .padding(4)
                        .frame(maxWidth: 100)
                    TextField("time(s)", text: $habit.metric ?? "")
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .submitLabel(.done)
                    Text("per \(goalRepeat == .daily ? "day" : "week")")
                        .font(.callout)
                        .foregroundColor(.secondary)*/
                }
                //.animation(.default, value: goalRepeat)
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            .listRowSeparator(.hidden)
        }
    }
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct EditHabitView_Previews: PreviewProvider {
    static var dataController = DataController()
    static var moc = dataController.container.viewContext
    static var previews: some View {
        Previewing(\.habit) { habit in
            ZStack {
                NavigationStack {
                    EditHabitView(habit: habit)
                }
            }
        }
    }
}
