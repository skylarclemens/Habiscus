//
//  Habit+CoreDataProperties.swift
//  Habiscus - Habit Tracker
//
//  Created by Skylar Clemens on 1/28/24.
//
//

import Foundation
import CoreData
import SwiftUI

extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var color: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var customCount: Bool
    @NSManaged public var defaultCount: Int16
    @NSManaged public var endDate: Date?
    @NSManaged public var frequency: String?
    @NSManaged public var goal: Int16
    @NSManaged public var icon: String?
    @NSManaged public var id: UUID?
    @NSManaged public var interval: Int16
    @NSManaged public var isArchived: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    @NSManaged public var progressMethod: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var unit: String?
    @NSManaged public var weekdays: String?
    @NSManaged public var type: String?
    @NSManaged public var actions: NSSet?
    @NSManaged public var notifications: NSSet?
    @NSManaged public var progress: NSSet?
    
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var createdDate: Date {
        createdAt ?? Date()
    }
    
    public var wrappedUnit: String {
        unit ?? ""
    }
    
    public var emojiIcon: String {
        icon ?? ""
    }
    
    public var wrappedType: HabitType {
        if let type {
            return HabitType(rawValue: type) ?? .build
        }
        return .build
    }
    
    public var totalValidDays: Int {
        guard let daysSinceStarted = self.startDate?.totalValidDaysBetween(Date(), in: self.weekdaysArray) else { return 0 }
        let daysSinceFirstProgress = self.activeProgressArray.first?.wrappedDate.totalValidDaysBetween(Date(), in: self.weekdaysArray) ?? 0
        
        return max(daysSinceStarted, daysSinceFirstProgress)
    }
    
    public var wrappedStartDate: Date {
        let startDate = self.startDate ?? Date()
        if let firstProgressDate = self.activeProgressArray.first?.wrappedDate,
           firstProgressDate < startDate {
            return firstProgressDate
        }
        return startDate
    }
    
    public var url: URL? {
        URL(string: "habiscus://open-habit?id=\(id!)")
    }
    
    public var weekdaysStrings: [String] {
        let weekdaysComponents = weekdays?.components(separatedBy: ",")
        return weekdaysComponents?.compactMap { $0.trimmingCharacters(in: .whitespaces) } ?? []
        
    }
    
    public var weekdaysArray: [Weekday] {
        weekdaysStrings.compactMap { Weekday(rawValue: $0.localizedLowercase) ?? nil }
    }
    
    public var weekdaysForCalc: [Weekday] {
        if self.goalFrequency == "weekly" {
            return [.sunday]
        }
        return self.weekdaysArray
    }
    
    public var formattedCreatedDate: String {
        createdAt?.formatted(.dateTime.day().month().year()) ?? "Date not found"
    }
    
    public var actionsArray: [Action] {
        let set = actions as? Set<Action> ?? []
        return set.sorted {
            $0.order < $1.order
        }
    }
    
    public var wrappedProgressMethod: HabitProgressMethod {
        if let progressMethod {
            return HabitProgressMethod(rawValue: progressMethod) ?? .counts
        }
        return .counts
    }
    
    public var progressArray: [Progress] {
        let set = progress as? Set<Progress> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }
    
    //Filter for progress that is not skipped
    public var activeProgressArray: [Progress] {
        progressArray.filter {
            !$0.isSkipped && $0.totalCount > 0 && weekdaysArray.contains($0.weekday!)
        }
    }
    
    public var notificationsArray: [Notification] {
        let set = notifications as? Set<Notification> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }
    
    public func findNotificationByDay(_ day: Int) -> Notification? {
        if let notification = notificationsArray.first(where: { $0.scheduledDay == Int16(day) }) {
            return notification
        }
        return nil
    }
    
    public var lastUpdatedDate: Date {
        lastUpdated ?? Date()
    }
    
    public var habitColor: Color {
        Color(color ?? "habiscusPink")
    }
    
    public var goalNumber: Int {
        if wrappedProgressMethod == .counts {
            Int(goal)
        } else {
            actionsArray.count
        }
    }
    
    // TODO: Switch to Goal
    public var goalInterval: Int {
        Int(interval)
    }
    
    public var defaultCountNumber: Int {
        Int(defaultCount)
    }
    
    public var goalFrequency: String {
        frequency ?? ""
    }
    
    public var allCountsArray: [Count] {
        var tempCountArray: [Count] = []
        progressArray.forEach { item in
            item.countsArray.forEach { count in
                tempCountArray.append(count)
            }
        }
        return tempCountArray
    }
    
    public func findProgress(from date: Date) -> Progress? {
        guard !self.progressArray.isEmpty else { return nil }
        var progressDate = date
        if goalFrequency == "weekly" {
            progressDate = date.startOfWeek()
        }
        let progressOnDate = self.progressArray.first(where: {
            Calendar.current.isDate($0.wrappedDate, inSameDayAs: progressDate)
        })
        return progressOnDate
    }
    
    public func lastUpdatedProgress() -> Progress {
        return self.progressArray.reduce(self.progressArray[0], {
            $0.wrappedLastUpdated > $1.wrappedLastUpdated ? $0 : $1
        })
    }
    
    public func mostRecentCount(from date: Date) -> Count? {
        guard let progress = findProgress(from: date) else {
            return nil
        }
        
        if progress.countsArray.count > 0 {
            return progress.countsArray.reduce(progress.countsArray[0], {
                $0.wrappedCreatedDate > $1.wrappedCreatedDate ? $0 : $1
            })
        }
        return nil
    }
    
    public func getCountByDate(from date: Date) -> Int {
        guard let progress = findProgress(from: date) else {
            return 0
        }
        return progress.totalCount
    }
    
    // Compares day the habit was first created and day since first progress to find starting day
    // Divides total completed progress count over number of days since each day has one progress object
    // Returns percentage
    public func getSuccessPercentage() -> Double? {
        guard self.totalValidDays > 0 else { return nil }
        
        var successPercentage: Double = 0
        
        if self.frequency == "weekly" {
            let totalValidWeeks = calculateTotalValidWeeks()
            var completedProgress = calculateCompletedWeeks()
            let totalSkippedWeeks = calculateSkippedWeeks()
            guard totalValidWeeks > 0 else { return nil }
            
            if self.wrappedType == .quit {
                completedProgress = totalValidWeeks - completedProgress
            }
            
            successPercentage = (Double(completedProgress) / Double(totalValidWeeks - totalSkippedWeeks) * 100)
        } else {
            var completedProgress = progressArray.filter { $0.completed }.count
            let skippedProgress = progressArray.filter { $0.isSkipped }.count
            
            if self.wrappedType == .quit {
                let totalQuitCompleted = self.totalValidDays - progressArray.count
                completedProgress = completedProgress + totalQuitCompleted
            }
            
            successPercentage = (Double(completedProgress) / Double(self.totalValidDays - skippedProgress) * 100)
        }
        
        return successPercentage
    }
    
    private func calculateTotalValidWeeks() -> Int {
        guard let startDate = self.startDate else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.weekOfYear], from: startDate, to: today)
        return (components.weekOfYear ?? 0) + 1
    }
    
    private func calculateCompletedWeeks() -> Int {
        let calendar = Calendar.current
        var completedWeeks: Set<Int> = []
        
        for progress in progressArray {
            let weekOfYear = calendar.component(.weekOfYear, from: progress.date!)
            let isCompleted = self.wrappedType == .quit ? !progress.completed : progress.completed
            if isCompleted {
                completedWeeks.insert(weekOfYear)
            }
        }
        
        return completedWeeks.count
    }
    
    private func calculateSkippedWeeks() -> Int {
        let calendar = Calendar.current
        var skippedWeeks: Set<Int> = []
        for progress in progressArray where progress.isSkipped {
            let weekOfYear = calendar.component(.weekOfYear, from: progress.date!)
            skippedWeeks.insert(weekOfYear)
        }
        
        return skippedWeeks.count
    }
    
    // Starts progress array at most recent, assumed that progress is array is already sorted
    // If first progress is not completed or is more than one day from today, returns a streak of 0
    // Returns first, most recent, streak of streak array
    public func getCurrentStreak() -> Int {
        guard let mostRecentProgress = progressArray.last(where: { $0.isCompleted && !$0.isSkipped }) else { return 0 }
        
        guard let progressDate = Date().closestPreviousWeekday(in: self.weekdaysForCalc),
              let closestProgress = self.findProgress(from: progressDate)
        else {
            if Calendar.current.isDateInToday(mostRecentProgress.wrappedDate) && mostRecentProgress.isCompleted { return 1 }
            return 0
        }
        
        var streaks: [Int] = []
        if Calendar.current.isDateInToday(mostRecentProgress.wrappedDate) || (closestProgress.isCompleted) {
            streaks = calculateStreaksArray(from: progressArray.reversed(), onDays: self.weekdaysForCalc)
        }
        return streaks.first ?? 0
    }
    
    // Adds to streak if compared dates are completed and proper length apart
    // Returns array of all streaks
    public func calculateStreaksArray(from: [Progress]? = nil, onDays daysToCheck: [Weekday]) -> [Int] {
        let refArray: [Progress] = from ?? self.progressArray
        var streakArray: [Int] = []
        var streak = 0
        
        for (progress, refProgress) in zip(refArray.dropFirst(), refArray) {
            if let progressWeekday = progress.weekday, let refProgressWeekday = refProgress.weekday {
                if !daysToCheck.contains(progressWeekday) || !daysToCheck.contains(refProgressWeekday) { continue }
            }
            if refProgress.isSkipped { continue }
            
            var isRefNextWeekdayDate: Bool = false
            if let findWeekdayDate = progress.wrappedDate.findWeekdayDate(in: daysToCheck, direction: .forward) {
                isRefNextWeekdayDate = Calendar.current.isDate(findWeekdayDate, inSameDayAs: refProgress.wrappedDate)
            }
            
            if progress.isSkipped && refProgress.isCompleted && isRefNextWeekdayDate {
                streak += 1
            } else if progress.isCompleted && refProgress.isCompleted && isRefNextWeekdayDate {
                streak += 1
            } else {
                if streak > 0 || refProgress.isCompleted {
                    streakArray.append(streak + 1)
                }
                streak = 0
            }
        }
        
        if let lastProgress = refArray.last,
           let lastProgressWeekday = lastProgress.weekday,
           daysToCheck.contains(lastProgressWeekday) && lastProgress.isCompleted && !lastProgress.isSkipped {
            streakArray.append(streak + 1)
        } else if streak > 0 {
            streakArray.append(streak)
        }
        
        return streakArray
    }
    
    public func getCurrentQuitStreak() -> Int {
        let mostRecentBreak = progressArray.last(where: { !$0.isCompleted && !$0.isSkipped })?.wrappedDate ?? self.wrappedStartDate
        guard !Calendar.current.isDateInToday(mostRecentBreak) else { return 0 }
        
        let validDatesBetween = mostRecentBreak.validDaysBetween(Date(), in: self.weekdaysForCalc) ?? []
        
        return calculateQuitStreak(in: validDatesBetween)
    }
    
    public func calculateQuitStreak(in dates: [Date]) -> Int {
        var streak = 0
        for currDate in dates {
            if let progress = self.findProgress(from: currDate),
               !progress.isCompleted || progress.isSkipped {
                continue
            }
            streak += 1
        }
        
        return streak;
    }
    
    public func calculateQuitStreaksArray(from: [Date]? = nil) -> [Int] {
        let refArray: [Date] = from ?? []
        var streakArray: [Int] = []

        for (date, refDate) in zip(refArray.dropFirst(), refArray) {
            let datesToCheck = date.validDaysBetween(refDate, in: self.weekdaysForCalc) ?? []
            streakArray.append(calculateQuitStreak(in: datesToCheck))
        }
        
        return streakArray
    }
    
    public func getLongestQuitStreak() -> Int {
        var allBreakDates = self.progressArray.filter { !$0.isCompleted && !$0.isSkipped }.map { $0.wrappedDate }
        allBreakDates.insert(self.wrappedStartDate, at: 0)
        allBreakDates.append(Date())
        return calculateQuitStreaksArray(from: allBreakDates.reversed()).max() ?? 0
    }
    
    // Gets the highest number in the streak array
    public func getLongestStreak() -> Int {
        calculateStreaksArray(from: progressArray.reversed(), onDays: self.weekdaysForCalc).max() ?? 0
    }
}

// MARK: Generated accessors for actions
extension Habit {

    @objc(addActionsObject:)
    @NSManaged public func addToActions(_ value: Action)

    @objc(removeActionsObject:)
    @NSManaged public func removeFromActions(_ value: Action)

    @objc(addActions:)
    @NSManaged public func addToActions(_ values: NSSet)

    @objc(removeActions:)
    @NSManaged public func removeFromActions(_ values: NSSet)

}

// MARK: Generated accessors for notifications
extension Habit {

    @objc(addNotificationsObject:)
    @NSManaged public func addToNotifications(_ value: Notification)

    @objc(removeNotificationsObject:)
    @NSManaged public func removeFromNotifications(_ value: Notification)

    @objc(addNotifications:)
    @NSManaged public func addToNotifications(_ values: NSSet)

    @objc(removeNotifications:)
    @NSManaged public func removeFromNotifications(_ values: NSSet)

}

// MARK: Generated accessors for progress
extension Habit {

    @objc(addProgressObject:)
    @NSManaged public func addToProgress(_ value: Progress)

    @objc(removeProgressObject:)
    @NSManaged public func removeFromProgress(_ value: Progress)

    @objc(addProgress:)
    @NSManaged public func addToProgress(_ values: NSSet)

    @objc(removeProgress:)
    @NSManaged public func removeFromProgress(_ values: NSSet)

}

extension Habit : Identifiable {

}
