//
//  ColorSchemeModifier.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import Foundation
import SwiftUI

enum DisplayMode: Int {
    case system, light, dark
    
    func displayOverride() {
        var uiStyle: UIUserInterfaceStyle
        
        switch self {
        case .system: uiStyle = .unspecified
        case .light: uiStyle = .light
        case .dark: uiStyle = .dark
        }
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.keyWindow?.overrideUserInterfaceStyle = uiStyle
    }
}

struct ColorSchemeModifier: ViewModifier {
    @AppStorage("selectedAppearance") var selectedAppearance: DisplayMode = .system
    
    func body(content: Content) -> some View {
        content
            .onChange(of: selectedAppearance) { newValue in
                print(selectedAppearance)
                selectedAppearance.displayOverride()
            }
            .onAppear {
                selectedAppearance.displayOverride()
            }
    }
}
