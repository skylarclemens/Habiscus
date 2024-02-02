//
//  ColorPickerView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import SwiftUI

struct ColorPickerView: View {
    @Binding var selection: String
    let colorOptions = ["habiscusPink", "habiscusBlue", "habiscusGreen", "habiscusPurple"]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(colorOptions, id: \.self) { color in
                    Button {
                        selection = color
                    } label: {
                        if selection == color {
                            Circle()
                                .strokeBorder(Color(color), lineWidth: 6)
                                .frame(width: 30, height: 30)
                        } else {
                            Circle()
                                .fill(Color(color))
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(selection: .constant("habiscusPink"))
    }
}
