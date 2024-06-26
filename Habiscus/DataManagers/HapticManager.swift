//
//  HapticManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/4/23.
//

import Foundation
import CoreHaptics
import UIKit.UINotificationFeedbackGenerator

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    var feedbackGenerator = UINotificationFeedbackGenerator()
    var hapticEngine: CHHapticEngine?
    var hapticsEnabled: Bool = true
    
    func toggleHaptics() {
        hapticsEnabled.toggle()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Error starting haptic engine \(error.localizedDescription)")
        }
    }
    
    private func createSection(_ startTime: Double, parameters: [CHHapticEventParameter]) -> [CHHapticEvent] {
        let delay = 0.05
        let duration = 0.1
        let eventsCount = 4
        var events = [CHHapticEvent]()
        (0...eventsCount - 1).enumerated().forEach { index, _ in
            let relativeTime = startTime + ((duration + delay) * Double(index))
            events.append(CHHapticEvent(eventType: .hapticContinuous, parameters: parameters, relativeTime: relativeTime, duration: duration))
        }
        return events
    }
    
    func welcomeHaptic() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        for i in stride(from: 0.3, to: 1.5, by: 0.3) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(i*3))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(i*3))
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func completionSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        for i in stride(from: 0, to: 0.2, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i)
            events.append(event)
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func simpleSuccess() {
        feedbackGenerator.notificationOccurred(.success)
    }
    
    func simpleUndo() {
        feedbackGenerator.notificationOccurred(.warning)
    }
    
    func simpleError() {
        feedbackGenerator.notificationOccurred(.error)
    }
}
