//
//  AlertView.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import SwiftUI

struct AlertView: View {
    let role: AlertRole? = .regular
    let title: String?
    var message: String?
    var isLoading: Bool?
    
    init(title: String? = nil, message: String? = nil, isLoading: Bool? = nil) {
        self.title = title
        self.message = message
        self.isLoading = isLoading
    }
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .font(.system(.headline, design: .rounded))
            }
            if let message = message {
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
            }
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 24)
        .background(
            Capsule()
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.1), radius: 3, y: 3)
        )
    }
    
    enum AlertRole {
        case regular, destructive, loading
    }
}

#Preview {
    AlertView(title: "Test")
}
