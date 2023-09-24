//
//  EventManager.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/22.
//

import Foundation
import EventKit

struct EventCellData {
    let event: EKEvent
    let length: Int
    let isStartDay: Bool
}

struct CalendarDate: Identifiable {
    let id = UUID()
    let date: Date?
    var eventCells: [EventCellData?]
    init(date: Date?, cells: Int) {
        self.date = date
        eventCells = [EventCellData?](repeating: nil, count: cells)
    }
}

class CalendarManager: ObservableObject {
    var store = EKEventStore()
    @Published var events: [EKEvent]? = nil
    @Published var reminders: [EKReminder]? = nil
    @Published var showingMonth = Date()
    @Published var cells = 4
    @Published var calendarDates = [CalendarDate]()
    var startOfMonth: Date {
        calendar.startOfMonth(for: showingMonth)!
    }
    var startOfNextMonth: Date {
        calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
    }
    
    init() {
        Task {
            do {
                try await store.requestAccess(to: .event)
            } catch {
                print(error.localizedDescription)
            }
            do {
                try await store.requestAccess(to: .reminder)
            } catch {
                print(error.localizedDescription)
            }
            createCalendarDates()
            NotificationCenter.default.addObserver(self, selector:#selector(createCalendarDates) , name: .EKEventStoreChanged, object: store)
        }
    }
    
    func fetchEvents() {
//        withStart <= 取得する範囲 < end
        let predicate = store.predicateForEvents(withStart: startOfMonth, end: startOfNextMonth, calendars: nil)
        self.events = self.store.events(matching: predicate)
    }
    
    func fetchReminder() {
//        withDueDateStarting < 取得する範囲 <= ending
        let start = calendar.date(byAdding: .second, value: -1, to: startOfMonth)
        let end = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        store.fetchReminders(matching: predicate) {reminder in
            DispatchQueue.main.async {
                self.reminders = reminder
            }
        }
    }
    
    @objc func createCalendarDates() {
        fetchEvents()
        fetchReminder()
        
        self.cells = 4
        self.calendarDates = [CalendarDate]()
        let daysInMonth = calendar.daysInMonth(for: showingMonth)!
        for day in 0..<daysInMonth {
            calendarDates.append(CalendarDate(date: calendar.date(byAdding: .day, value: day, to: startOfMonth), cells: cells))
        }
        
        if let events = events {
            for event in events {
                let start = max(startOfMonth, event.startDate)
                let end = calendar.date(byAdding: .second, value: -1, to: min(startOfNextMonth, event.endDate))!
                let startDayNumber = calendar.component(.day, from: start)
                let endDayNumber = max(startDayNumber, calendar.component(.day, from: end))
                var cellNumber = 0
                var assigned = false
                for i in 0..<cells {
                    if calendarDates[startDayNumber-1].eventCells[i] == nil {
                        cellNumber = i
                        assigned.toggle()
                        break
                    }
                }
                if !assigned {
                    for i in 0..<daysInMonth {
                        calendarDates[i].eventCells.append(nil)
                    }
                    cellNumber = cells
                    cells += 1
                }
                let fullLength = endDayNumber-startDayNumber+1
                for i in 0..<fullLength {
                    let length = fullLength-i
                    calendarDates[startDayNumber+i-1].eventCells[cellNumber] = EventCellData(event: event, length: length, isStartDay: i==0)
                }
            }
        }
        
        let firstDay = calendarDates.first!
        let lastDay = calendarDates.last!
        let firstDate = firstDay.date!
        let lastDate = lastDay.date!
        let firstDateWeekday = calendar.weekday(for: firstDate)!
        let lastDateWeekday = calendar.weekday(for: lastDate)!
        let firstWeekEmptyDays = firstDateWeekday - 1
        let lastWeekEmptyDays = 7 - lastDateWeekday
        for _ in 0..<firstWeekEmptyDays {
            calendarDates.insert(CalendarDate(date: nil, cells: cells), at: 0)
        }
        for _ in 0..<lastWeekEmptyDays {
            calendarDates.append(CalendarDate(date: nil, cells: cells))
        }
    }
}
