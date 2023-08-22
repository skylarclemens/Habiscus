//
//  ToastViewModifier.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import SwiftUI

struct ToastViewModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toastContent: () -> ToastContent
    
    init(
        isPresented: Binding<Bool>,
        content toastContent: @escaping () -> ToastContent
    ) {
        self._isPresented = isPresented
        self.toastContent = toastContent
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    toastContent()
                }
            }
    }
}
