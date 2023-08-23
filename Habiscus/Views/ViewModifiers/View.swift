//
//  View.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import Foundation
import SwiftUI

extension View {
    func colorSchemeStyle() -> some View {
        modifier(ColorSchemeViewModifier())
    }
    
    func toast(isPresenting: Binding<Bool>,
               @ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(ToastViewModifier(isPresented: isPresenting, content: content))
    }
    
    func emptyState(isEmpty: Bool,
                    emptyContent: @escaping () -> some View) -> some View {
        modifier(EmptyViewModifier(isEmpty: isEmpty, emptyContent: emptyContent))
    }
}
