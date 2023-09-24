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
    @Published var events: [EKEvent]? = nil
    @Published var reminders: [EKReminder]? = nil
    
    @Published var cells = 4
    @Published var calendarDates = [CalendarDate]()
    
    @Published var showingMonth = Date()
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
    
    func fetchReminder(completion: @escaping () -> Void) {
        //        withDueDateStarting < 取得する範囲 <= ending
        let start = calendar.date(byAdding: .second, value: -1, to: startOfMonth)
        let end = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)
        let predicate = store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
        store.fetchReminders(matching: predicate) {reminder in
            DispatchQueue.main.async {
                self.reminders = reminder
                completion()
            }
        }
    }
    
    @objc func createCalendarDates() {
        fetchEvents()
        //        fetchReminderの処理が完了してから次の処理を行う
        fetchReminder {
            //        calendarDatesを初期化
            self.cells = 4
            self.calendarDates = [CalendarDate]()
            let daysInMonth = calendar.daysInMonth(for: self.showingMonth)!
            for day in 0..<daysInMonth {
                self.calendarDates.append(CalendarDate(date: calendar.date(byAdding: .day, value: day, to: self.startOfMonth), cells: self.cells))
            }
            
            //        イベントの情報をセルに割り当てる
            if let events = self.events {
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
            if let reminders = self.reminders {
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
}
