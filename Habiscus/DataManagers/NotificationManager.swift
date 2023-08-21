//
//  NotificationManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import Foundation
import UserNotifications
import CoreData

class NotificationManager: ObservableObject {
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    
    func registerLocal() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else {return}
        }
    }
    
    func setReminderNotification(for habit: Habit, in context: NSManagedObjectContext, id: UUID? = nil, on weekday: Int, at selectedTime: Date, body: String, title: String) {
        var notificationId: UUID
        if let existingId = id {
            notificationId = existingId
        } else {
            notificationId = UUID()
            let newNotification = Notification(context: context)
            newNotification.id = notificationId
            newNotification.createdAt = Date()
            newNotification.scheduledDay = Int16(weekday)
            newNotification.time = selectedTime
            newNotification.habit = habit
        }
        
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
        let request = UNNotificationRequest(identifier: notificationId.uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
        }
    }
    
    func removeNotification(_ notification: Notification) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [notification.id!.uuidString])
    }
    
    func removeNotifications(_ notificationIds: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIds)
    }
    
    func removeAllNotifiations() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
