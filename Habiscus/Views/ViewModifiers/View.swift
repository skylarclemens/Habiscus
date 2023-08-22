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
        modifier(ColorSchemeModifier())
    }
    
    func toast(isPresenting: Binding<Bool>,
               @ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(ToastViewModifier(isPresented: isPresenting, content: content))
    }
}
