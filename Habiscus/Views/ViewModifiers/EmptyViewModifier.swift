//
//  EmptyViewModifier.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import Foundation
import SwiftUI

struct EmptyViewModifier<EmptyContent: View>: ViewModifier {
    var isEmpty: Bool
    let emptyContent: () -> EmptyContent
    
    func body(content: Content) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            content
        }
    }
}
