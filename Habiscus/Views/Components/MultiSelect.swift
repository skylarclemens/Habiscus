//
//  MultiSelectView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct SelectOption<T: Hashable & Identifiable>: Hashable, Identifiable {
    let text: String
    let value: T
    
    init(_ text: String, _ value: T) {
        self.text = text
        self.value = value
    }
    
    var id: T.ID { value.id }
}

struct MultiSelect<T: Hashable & Identifiable>: View {
    @Binding var selected: Set<T>
    var options: [SelectOption<T>]
    
    var body: some View {
        List {
            ForEach(options) { option in
                let optionSelected = selected.contains(option.value)
                Button {
                    if optionSelected {
                        selected.remove(option.value)
                    } else {
                        selected.insert(option.value)
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text(option.text)
                            .foregroundColor(.primary)
                        Spacer()
                        if optionSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }
}

struct MultiSelect_Previews: PreviewProvider {
    @State static var selected: Set<Weekday> = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    static let options: [SelectOption<Weekday>] = Weekday.allValues.map { SelectOption($0.rawValue.localizedCapitalized, $0) }
    static var previews: some View {
        NavigationStack {
            Form {
                MultiSelect(
                    selected: $selected,
                    options: options)
            }
        }
    }
}
