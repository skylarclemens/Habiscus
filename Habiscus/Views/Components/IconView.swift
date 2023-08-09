//
//  IconView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/9/23.
//

import SwiftUI

struct IconView: View {
    var char: String
    var size: CGFloat = 24
    var color: Color = .clear
    var body: some View {
        Text(char)
            .font(.system(size: size))
            .frame(width: size*2, height: size*2)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
            )
    }
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(char: Emoji.exampleEmoji.char, size: 32, color: .pink.opacity(0.125))
    }
}
