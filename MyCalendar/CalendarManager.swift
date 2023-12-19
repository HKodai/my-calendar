//
//  EventManager.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/22.
//

import Foundation
import EventKit

struct EventReminderCellData {
    let event: EKEvent?
    let reminder: EKReminder?
    let length: Int
    let isStartDay: Bool
}

struct CalendarDate {
    let date: Date?
    var eventReminderCells: [EventReminderCellData?]
    
    init(date: Date?, cells: Int) {
        self.date = date
        eventReminderCells = [EventReminderCellData?](repeating: nil, count: cells)
    }
}

class CalendarManager: ObservableObject {
    var store = EKEventStore()
    @Published var monthEvents: [EKEvent]? = nil
    @Published var dayEvents: [EKEvent]? = nil
    @Published var monthReminders: [EKReminder]? = nil
    @Published var dayReminders: [EKReminder]? = nil
    @Published var allReminders: [EKReminder]? = nil
    
    @Published var cells = 4
    @Published var calendarDates = [CalendarDate]()
    
    @Published var showingMonth = Date()
    @Published var showingDate = Date()
    var startOfMonth: Date {
        calendar.startOfMonth(for: showingMonth)!
    }
    var startOfNextMonth: Date {
        calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
    }
    
    init() {
        Task {
            do {
                if #available(iOS 17.0, *) {
                    // おそらくここで黄色のエラーが出る
                    store.requestFullAccessToEvents(completion: {granted, error in
                        if granted {
                            self.createCalendarDates()
                        }})
                }else {
                    try await store.requestAccess(to: .event)
                }
            } catch {
                print(error.localizedDescription)
            }
            do {
                if #available(iOS 17.0, *) {
                    try await store.requestFullAccessToReminders()
                }else {
                    try await store.requestAccess(to: .reminder)
                }
            } catch {
                print(error.localizedDescription)
            }
            NotificationCenter.default.addObserver(self, selector:#selector(createCalendarDates) , name: .EKEventStoreChanged, object: store)
            NotificationCenter.default.addObserver(self, selector:#selector(fetchDayEvent) , name: .EKEventStoreChanged, object: store)
            NotificationCenter.default.addObserver(self, selector:#selector(fetchDayReminder) , name: .EKEventStoreChanged, object: store)
            NotificationCenter.default.addObserver(self, selector:#selector(fetchAllReminder) , name: .EKEventStoreChanged, object: store)
        }
    }
    
    func fetchMonthEvent() {
        //        withStart <= 取得する範囲 < end
        let predicate = store.predicateForEvents(withStart: startOfMonth, end: startOfNextMonth, calendars: nil)
        DispatchQueue.main.async {
            self.monthEvents = self.store.events(matching: predicate)
        }
    }
    
    @objc func fetchDayEvent() {
        let start = showingDate
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 1, of: start)!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        self.dayEvents = store.events(matching: predicate)
    }
    
    func fetchMonthReminder(completion: @escaping () -> Void) {
        //        withDueDateStarting < 取得する範囲 <= ending
        let start = calendar.date(byAdding: .second, value: -1, to: startOfMonth)
        let end = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        store.fetchReminders(matching: predicate) {reminder in
            DispatchQueue.main.async {
                self.monthReminders = reminder
                completion()
            }
        }
    }
    
    @objc func fetchDayReminder() {
        let start = calendar.date(byAdding: .second, value: -1, to: showingDate)
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: showingDate)
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        store.fetchReminders(matching: predicate) {reminder in
            DispatchQueue.main.async {
                self.dayReminders = reminder
            }
        }
    }
    
    @objc func fetchAllReminder() {
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        store.fetchReminders(matching: predicate) {reminder in
            DispatchQueue.main.async {
                self.allReminders = reminder
            }
        }
    }
    
    @objc func createCalendarDates() {
        fetchMonthEvent()
        //        fetchReminderの処理が完了してから次の処理を行う
        fetchMonthReminder {
            //        calendarDatesを初期化
            self.cells = 4
            self.calendarDates = [CalendarDate]()
            let daysInMonth = calendar.daysInMonth(for: self.showingMonth)!
            for day in 0..<daysInMonth {
                self.calendarDates.append(CalendarDate(date: calendar.date(byAdding: .day, value: day, to: self.startOfMonth), cells: self.cells))
            }
            
            //        イベントの情報をセルに割り当てる
            if let events = self.monthEvents {
                for event in events {
                    let start = max(self.startOfMonth, event.startDate)
                    let end = calendar.date(byAdding: .second, value: -1, to: min(self.startOfNextMonth, event.endDate))!
                    let startDayNumber = calendar.component(.day, from: start)
                    let endDayNumber = max(startDayNumber, calendar.component(.day, from: end))
                    var cellNumber = 0
                    var assigned = false
                    
                    //                空いているセルがあればそこに入れる
                    for i in 0..<self.cells {
                        if self.calendarDates[startDayNumber-1].eventReminderCells[i] == nil {
                            cellNumber = i
                            assigned.toggle()
                            break
                        }
                    }
                    //                空きが無ければセルを追加
                    if !assigned {
                        for i in 0..<daysInMonth {
                            self.calendarDates[i].eventReminderCells.append(nil)
                        }
                        cellNumber = self.cells
                        self.cells += 1
                    }
                    let fullLength = endDayNumber-startDayNumber+1
                    //                開始日と同じ行に入れ続ける
                    for i in 0..<fullLength {
                        let length = fullLength-i
                        self.calendarDates[startDayNumber+i-1].eventReminderCells[cellNumber] = EventReminderCellData(event: event, reminder: nil, length: length, isStartDay: i==0)
                    }
                }
            }
            
            //        リマインダーの情報をセルに割り当てる
            if let reminders = self.monthReminders {
                for reminder in reminders {
                    let dayNumber = reminder.dueDateComponents!.day!
                    var cellNumber = 0
                    var assigned = false
                    
                    for i in 0..<self.cells {
                        if self.calendarDates[dayNumber-1].eventReminderCells[i] == nil {
                            cellNumber = i
                            assigned.toggle()
                            break
                        }
                    }
                    if !assigned {
                        for i in 0..<daysInMonth {
                            self.calendarDates[i].eventReminderCells.append(nil)
                        }
                        cellNumber = self.cells
                        self.cells += 1
                    }
                    self.calendarDates[dayNumber-1].eventReminderCells[cellNumber] = EventReminderCellData(event: nil, reminder: reminder, length: 1, isStartDay: true)
                }
            }
            
            //        使わないマスを埋める
            let firstDay = self.calendarDates.first!
            let lastDay = self.calendarDates.last!
            let firstDate = firstDay.date!
            let lastDate = lastDay.date!
            let firstDateWeekday = calendar.weekday(for: firstDate)!
            let lastDateWeekday = calendar.weekday(for: lastDate)!
            let firstWeekEmptyDays = firstDateWeekday - 1
            let lastWeekEmptyDays = 7 - lastDateWeekday
            for _ in 0..<firstWeekEmptyDays {
                self.calendarDates.insert(CalendarDate(date: nil, cells: self.cells), at: 0)
            }
            for _ in 0..<lastWeekEmptyDays {
                self.calendarDates.append(CalendarDate(date: nil, cells: self.cells))
            }
        }
    }
    
    func createEvent(title: String, startDate: Date, endDate: Date, colorCode: String) {
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
            UserDefaults.standard.set(colorCode, forKey: event.eventIdentifier)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func modifyEvent(event: EKEvent, title: String, startDate: Date, endDate: Date) {
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteEvent(event: EKEvent) {
        do {
            try store.remove(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createReminder(title: String, dueDate: Date?, colorCode: String) {
        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        if let date = dueDate {
            reminder.dueDateComponents = calendar.dateComponents([.calendar, .year, .month, .day, .hour, .minute], from: date)
        } else {
            reminder.dueDateComponents = nil
        }
        reminder.calendar = store.defaultCalendarForNewReminders()
        do {
            try store.save(reminder, commit: true)
            UserDefaults.standard.set(colorCode, forKey: reminder.calendarItemIdentifier)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func modifyReminder(reminder: EKReminder, title: String, dueDate: Date?, colorCode: String) {
        reminder.title = title
        if let date = dueDate {
            reminder.dueDateComponents = calendar.dateComponents([.calendar, .year, .month, .day, .hour, .minute], from: date)
        } else {
            reminder.dueDateComponents = nil
        }
        reminder.calendar = store.defaultCalendarForNewReminders()
        do {
            try store.save(reminder, commit: true)
            UserDefaults.standard.set(colorCode, forKey: reminder.calendarItemIdentifier)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteReminder(reminder: EKReminder) {
        do {
            try store.remove(reminder, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}
