//
//  ToastManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/22/23.
//

import Foundation

class ToastManager: ObservableObject {
    static var shared = ToastManager()
    
    @Published var showAlert: Bool = false
    @Published var successTitle: String? = nil
    @Published var successMessage: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
}
