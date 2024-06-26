//
//  ScheduleView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/12/17.
//

import SwiftUI
import EventKit

enum ScheduleCompType {
    case subject
    case event
    case reminder
}

struct ScheduleComponent: Hashable {
    let id: String?
    let title: String
    let comptype: ScheduleCompType
    let startDate: Date
    let endDate: Date?
    let colorCode: String?
}

func createScheduleArray(date: Date, timetableArray: [Timetable], eventArray: [EKEvent], reminderArray: [EKReminder]) -> [ScheduleComponent] {
    var arr: [ScheduleComponent] = []
    // 時間割
    let weekday = calendar.weekday(for: date)!-1
    for timetable in timetableArray {
        if let start = timetable.startDate,
           let end = timetable.endDate {
            if calendar.startOfDay(for: start) <= date && date <= end && timetable.weekDays[weekday] {
                for period in 0..<timetable.showingPeriods {
                    let startTime = timetable.periods[period].startTime
                    let endTime = timetable.periods[period].endTime
                    if let subject = timetable.table[weekday][period] {
                        if !subject.noClass.contains(date) {
                            var startDate = Date()
                            var endDate: Date? = nil
                            var startDateComps = calendar.dateComponents([.year, .month, .day], from: date)
                            var endDateComps = calendar.dateComponents([.year, .month, .day], from: date)
                            if let startHour = startTime.hour,
                               let startMinute = startTime.minute {
                                startDateComps.hour = startHour
                                startDateComps.minute = startMinute
                            }
                            startDate = calendar.date(from: startDateComps)!
                            if let endHour = endTime.hour,
                               let endMinute = endTime.minute {
                                endDateComps.hour = endHour
                                endDateComps.minute = endMinute
                            }
                            endDate = calendar.date(from: endDateComps)
                            arr.append(ScheduleComponent(id: nil, title: subject.title, comptype: .subject, startDate: startDate, endDate: endDate, colorCode: subject.colorCode))
                        }
                    }
                }
            }
        }
    }
    // イベント
    for event in eventArray {
        let colorCode = UserDefaults.standard.string(forKey: event.eventIdentifier) ?? "CCCCCC"
        arr.append(ScheduleComponent(id: event.eventIdentifier, title: event.title, comptype: .event, startDate: event.startDate, endDate: event.endDate, colorCode: colorCode))
    }
    // リマインダー
    for reminder in reminderArray {
        let colorCode = UserDefaults.standard.string(forKey: reminder.calendarItemIdentifier) ?? "000000"
        arr.append(ScheduleComponent(id: reminder.calendarItemIdentifier, title: reminder.title, comptype: .reminder, startDate: reminder.dueDateComponents!.date!, endDate: nil, colorCode: colorCode))
    }
    arr.sort(by: { a, b -> Bool in
        if a.startDate != b.startDate {
            return a.startDate <= b.startDate
        }
        if a.endDate == nil {
            return true
        } else if b.endDate == nil {
            return false
        }
        return a.endDate! <= b.endDate!
    })
    return arr
}

struct ScheduleView: View {
    @EnvironmentObject var timetableData: TimetableData
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var date: Date
    @State var isShowTimeteble = false
    @State var isShowEvent = false
    @State var isShowReminder = false
    @State var event: EKEvent? = nil
    @State var reminder: EKReminder? = nil
    var showingDayString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyy/MM/dd"
        return df.string(from: date)
    }
    
    var body: some View {
        Text(showingDayString)
            .padding()
        ScrollView {
            ForEach(createScheduleArray(date: date, timetableArray: timetableData.timetableArray, eventArray: calendarManager.dayEvents ?? [], reminderArray: calendarManager.dayReminders ?? []), id: \.self) { comp in
                if comp.comptype == .subject {
                    Button(action: {
                        isShowTimeteble.toggle()
                    }, label: {
                        SubjectEventComponentView(component: comp)
                    })
                } else if comp.comptype == .event {
                    Button(action: {
                        event = calendarManager.store.event(withIdentifier: comp.id!)
                        isShowEvent.toggle()
                    }, label: {
                        SubjectEventComponentView(component: comp)
                    })
                    .contextMenu {
                        Button(role: .destructive) {
                            if let event = calendarManager.store.event(withIdentifier: comp.id!) {
                                calendarManager.deleteEvent(event: event)
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                } else if comp.comptype == .reminder {
                    Button(action: {
                        let start = calendar.date(byAdding: .second, value: -1, to: date)
                        let end = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: date)
                        let predicate = calendarManager.store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
                        calendarManager.store.fetchReminders(matching: predicate) {reminders in
                            for reminder in reminders ?? [] {
                                if reminder.calendarItemIdentifier == comp.id! {
                                    self.reminder = reminder
                                    isShowReminder.toggle()
                                    break
                                }
                            }
                        }
                    }, label: {
                        ReminderComponentView(component: comp)
                    })
                    .contextMenu {
                        Button(role: .destructive) {
                            let start = calendar.date(byAdding: .second, value: -1, to: date)
                            let end = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: date)
                            let predicate = calendarManager.store.predicateForIncompleteReminders(withDueDateStarting: start, ending: end, calendars: nil)
                            calendarManager.store.fetchReminders(matching: predicate) {reminders in
                                for reminder in reminders ?? [] {
                                    if reminder.calendarItemIdentifier == comp.id! {
                                        calendarManager.deleteReminder(reminder: reminder)
                                        break
                                    }
                                }
                            }
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowTimeteble) {
            TimetableView()
        }
        .sheet(isPresented: $isShowEvent) {
            CreateEventView(event: $event)
        }
        .sheet(isPresented: $isShowReminder) {
            CreateReminderView(reminder: $reminder)
        }
    }
}
