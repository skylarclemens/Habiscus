//
//  TimePickerWheel.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/11/23.
//

import SwiftUI

struct TimePickerWheel: View {
    @Environment(\.managedObjectContext) private var childContext
    
    @State var time: (hours: Int, minutes: Int) = (hours: 0, minutes: 1)
    var totalInSeconds: Double {
        Double((time.hours * 3600) + time.minutes * 60)
    }
    
    @Binding var timerNumber: Double
    
    @State var openPopover: Bool = false
    var body: some View {
        Button {
            openPopover = true
        } label: {
            Text("\(time.hours) hr, \(time.minutes) min")
                .padding(EdgeInsets(top: 6, leading: 11, bottom: 6, trailing: 11))
                .background(Color(UIColor.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $openPopover) {
            HStack(spacing: 0) {
                Picker("hours", selection: $time.hours) {
                    ForEach(0...23, id: \.self) { num in
                        Text("\(num) hour\(num > 1 || num == 0 ? "s" : "")").tag(num)
                    }
                }
                .pickerStyle(.wheel)
                .clipShape(.rect.offset(x: -16))
                .padding(.trailing, -16)
                Picker("minutes", selection: $time.minutes) {
                    ForEach(0...59, id: \.self) { num in
                        Text("\(num) minute\(num > 1 || num == 0 ? "s" : "")").tag(num)
                    }
                }
                .pickerStyle(.wheel)
                .clipShape(.rect.offset(x: 16))
                .padding(.leading, -16)
            }
            .presentationCompactAdaptation(.popover)
        }
        .onChange(of: totalInSeconds) { newValue in
            self.timerNumber = totalInSeconds
        }
    }
}

#Preview {
    TimePickerWheel(timerNumber: .constant(0.0))
}
