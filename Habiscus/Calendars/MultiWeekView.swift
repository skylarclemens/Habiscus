//
//  WeekView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 7/27/23.
//

import SwiftUI

struct MultiWeekView: View {
    @Binding var selectedDate: Date
    private var week: Week {
        Week(initialDate: selectedDate)
    }
    private var allWeeks: [Week] {
        week.getRelatedWeeks()
    }
    
    @State private var currentIndex: Int = 0
    @GestureState private var currentTranslation: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(allWeeks.indices, id: \.self) { index in
                        HStack(spacing: 8) {
                            ForEach(allWeeks[index].currentWeek, id: \.self) { weekday in
                                let isSelectedDay = Calendar.current.isDate(selectedDate, inSameDayAs: weekday)
                                VStack {
                                    Text(weekday, format: .dateTime.weekday())
                                        .font(.caption)
                                    Text(weekday, format: .dateTime.day())
                                        .bold()
                                }
                                .foregroundColor(isSelectedDay ? .white : .primary)
                                .padding(8)
                                .frame(width: 42)
                                .background(isSelectedDay ? Color.habiscusPink : Color(UIColor.systemFill))
                                .opacity(isSelectedDay ? 1 : 0.75)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture {
                                    selectedDate = weekday
                                    currentIndex = 0
                                }
                            }
                        }
                        .frame(width: geo.size.width)
                    }
                }
                .frame(width: geo.size.width)
                .frame(maxHeight: .infinity)
                .offset(x: geo.size.width * CGFloat(currentIndex))
                .offset(x: currentTranslation)
                .animation(.spring(), value: currentTranslation)
                .gesture(
                    DragGesture()
                        .updating($currentTranslation) { value, state, _ in
                            if currentIndex == 1 && value.translation.width > 0 {
                                return
                            } else if currentIndex == -1 && value.translation.width < 0 {
                                return
                            }
                            state = value.translation.width
                        }.onEnded { value in
                            withAnimation(.interactiveSpring()) {
                                if value.predictedEndTranslation.width > 0 {
                                    currentIndex = min(currentIndex + 1, 1)
                                } else {
                                    currentIndex = max(currentIndex - 1, -1)
                                }
                            }
                        }
                )
                
            }
        }
    }
}

struct MultiWeekView_Previews: PreviewProvider {
    static var previews: some View {
        MultiWeekView(selectedDate: .constant(Date()))
    }
}
