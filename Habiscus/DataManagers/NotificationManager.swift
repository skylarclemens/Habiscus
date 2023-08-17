//
//  NotificationManager.swift
//  Habiscus
//
//  Created by Skylar Clemens on 8/17/23.
//

import Foundation
import UserNotifications

class NotificationManager {
    static func registerLocal(center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard granted else {return}
        }
    }
    
    static func setReminderNotification(id habitId: UUID, repeatValue: String, on selectedDateTime: Date, content: UNMutableNotificationContent) {
        let center = UNUserNotificationCenter.current()
        var dateComponents = DateComponents()
        if repeatValue == "Once" {
            dateComponents = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: selectedDateTime)
        } else if repeatValue == "Daily" {
            dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDateTime)
        } else if repeatValue == "Weekly" {
            dateComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedDateTime)
            dateComponents.weekday = 1
        } else {
            return
        }
        
        registerLocal(center: center)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeatValue != "Once" ? true : false)
        
        let request = UNNotificationRequest(identifier: habitId.uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
         }
    }
}
