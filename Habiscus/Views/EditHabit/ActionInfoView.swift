//
//  ActionInfoView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 11/13/23.
//

import SwiftUI

struct ActionInfoView: View {
    @Binding var information: ActionType?
    
    var body: some View {
        if let action = information {
            ZStack(alignment: .topTrailing) {
                VStack {
                    Button {
                        withAnimation {
                            information = nil
                        }
                    } label: {
                        Label("Close", systemImage: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .labelStyle(.iconOnly)
                }
                ZStack(alignment: .bottomLeading) {
                    Image(systemName: action.symbol())
                        .font(.system(size: 124))
                        .foregroundStyle(.white.opacity(0.125))
                        .offset(x: -40, y: 40)
                    VStack {
                        Text(action.label())
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(action.color())
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                    .shadow(color: action.color().opacity(0.25), radius: 4, y: 2)
            )
        }
    }
}

#Preview {
    ActionInfoView(information: .constant(.timer))
}
