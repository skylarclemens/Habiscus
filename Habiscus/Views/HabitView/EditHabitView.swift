//
//  EditHabitView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/18/23.
//

import SwiftUI

enum RepeatOptions: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, yearly, weekdays, weekends
    
    var id: Self { self }
}

struct EditHabitView: View {
    @Environment(\.managedObjectContext) private var childContext
    @Environment(\.dismiss) private var dismiss
    
    // New object if creating, and existing object if editing
    @ObservedObject var habit: Habit
    
    @State private var openEmojiPicker: Bool = false
    @FocusState private var focusedInput: FocusedField?
    enum FocusedField: Hashable {
        case goalCountField
    }
    
    @State private var frequency: RepeatOptions
    @State private var weekdays: Set<Weekday>
    @State private var startDate: Date
    @State var selectedEmoji: String? = nil
    private var weekdaysSelected: [RepeatOptions : Set<Weekday>] {
        return [
            .daily: [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
            .weekly: weekdays,
            .weekdays: [.monday, .tuesday, .wednesday, .thursday, .friday],
            .weekends: [.saturday, .sunday],
            .monthly: [],
            .yearly: []
        ]
    }
    
    init(habit: Habit) {
        self.habit = habit
        self._frequency = State(initialValue: RepeatOptions(rawValue: habit.frequency ?? "") ?? .daily)
        self._startDate = State(initialValue: habit.startDate ?? Calendar.current.startOfDay(for: Date()))
        self._weekdays = State(initialValue: (habit.weekdays != nil) ? Set(habit.weekdaysArray) : [Date().currentWeekday])
    }
    
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
                    Button {
                        openEmojiPicker = true
                    } label: {
                        VStack {
                            if let selectedEmoji = habit.icon {
                                Text(selectedEmoji)
                                    .font(.title)
                            } else {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .foregroundColor(Color(habit.color ?? "pink"))
                            }
                        }
                        .frame(width: 65, height: 65)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(habit.color ?? "pink").opacity(0.1))
                        )
                    }
                    ColorPickerView(selection: $habit.color ?? "pink")
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
                    TextField("count", value: $habit.goal, format: .number)
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
                    TextField("time(s)", text: $habit.unit ?? "")
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .submitLabel(.done)
                    Text("per \(habit.goalFrequency == "daily" ? "day" : "week")")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .listRowInsets(EdgeInsets())
            }
            .listRowSeparator(.hidden)
            DateOptions(frequency: $frequency, weekdays: $weekdays, interval: $habit.interval, startDate: $startDate, endDate: $habit.endDate)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let sortedDaysSelected = weekdaysSelected[frequency]!.sorted { Weekday.allValues.firstIndex(of: $0)! < Weekday.allValues.firstIndex(of: $1)! }
                    let daysSelectedArray = sortedDaysSelected.map { $0.rawValue.localizedCapitalized }
                    let daysSelected = daysSelectedArray.joined(separator: ", ")
                    habit.weekdays = daysSelected
                    habit.frequency = frequency.rawValue
                    habit.startDate = startDate
                    
                    // Save new/edited Habit in the child context
                    try? childContext.save()
                    if let parentContext = childContext.parent {
                        try? parentContext.save()
                    }
                    dismiss()
                }
                .disabled((habit.name ?? "").isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                if focusedInput == .goalCountField {
                    Spacer()
                    Button("Done") {
                        focusedInput = nil
                    }
                }
            }
        }
        .sheet(isPresented: $openEmojiPicker) {
            IconPickerView(selectedIcon: $habit.icon)
                .presentationDetents([.fraction(0.8), .large])
                .presentationDragIndicator(.visible)
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
