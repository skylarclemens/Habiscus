//
//  RemindersView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct RemindersView: View {
    @Binding var repeatValue: String
    @Binding var selectedDateTime: Date
    @Binding var selectedDay: Weekday
    
    let repeatOptions = ["Once", "Daily", "Weekly", "None"]
    var body: some View {
        VStack {
            Picker("Repeat", selection: $repeatValue) {
                ForEach(repeatOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(.segmented)
            VStack {
                if repeatValue == "Once" {
                    DatePicker("When?", selection: $selectedDateTime)
                } else if repeatValue == "Daily" {
                    DatePicker("What time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
                } else if repeatValue == "Weekly" {
                    HStack {
                        Picker("When?", selection: $selectedDay) {
                            ForEach(Weekday.allCases, id: \.self) {
                                Text($0.rawValue.localizedCapitalized).tag($0)
                            }
                        }
                        DatePicker("What day/time?", selection: $selectedDateTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                } else {
                    Text("No reminders set")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.background)
            )
        }
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .listRowInsets(EdgeInsets())
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView(repeatValue: .constant("Daily"), selectedDateTime: .constant(Date()), selectedDay: .constant(.monday))
    }
}
