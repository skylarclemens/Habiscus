//
//  FilterListView.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 1/25/24.
//

import SwiftUI

struct FilterListView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var showActive: Bool
    @Binding var showComplete: Bool
    @Binding var showSkipped: Bool
    
    var body: some View {
        List {
            Section("Show sections") {
                Group {
                    Toggle("Active", isOn: $showActive.animation())
                    Toggle("Complete", isOn: $showComplete.animation())
                    Toggle("Skipped", isOn: $showSkipped.animation())
                }
                .foregroundStyle(.primary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    FilterListView(showActive: .constant(true), showComplete: .constant(true), showSkipped: .constant(true))
}
