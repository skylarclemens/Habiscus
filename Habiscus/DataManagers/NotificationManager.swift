//
//  NotificationManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    func registerLocal() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else {return}
        }
    }
    
    func setReminderNotification(id habitId: UUID, on weekday: Int, at selectedTime: Date, body: String, title: String) {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        var components = DateComponents()
        components.weekday = weekday
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        registerLocal()
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "\(habitId.uuidString)-\(weekday)", content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
}
