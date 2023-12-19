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

struct ScheduleComponent: Identifiable {
    var id = UUID()
    let title: String
    let comptype: ScheduleCompType
    let startDate: Date?
    let endDate: Date?
    let colorCode: String?
}

func createScheduleArray(date: Date, timetableArray: [Timetable], eventArray: [EKEvent]) -> [ScheduleComponent] {
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
                            var startDate: Date? = nil
                            var endDate: Date? = nil
                            var startDateComps = calendar.dateComponents([.year, .month, .day], from: date)
                            var endDateComps = calendar.dateComponents([.year, .month, .day], from: date)
                            if let startHour = startTime.hour,
                               let startMinute = startTime.minute {
                                startDateComps.hour = startHour
                                startDateComps.minute = startMinute
                                startDate = calendar.date(from: startDateComps)
                            }
                            if let endHour = endTime.hour,
                               let endMinute = endTime.minute {
                                endDateComps.hour = endHour
                                endDateComps.minute = endMinute
                                endDate = calendar.date(from: endDateComps)
                            }
                            arr.append(ScheduleComponent(title: subject.title, comptype: .subject, startDate: startDate, endDate: endDate, colorCode: subject.colorCode))
                        }
                    }
                }
            }
        }
    }
    // イベント
    for event in eventArray {
        let colorCode = UserDefaults.standard.string(forKey: event.eventIdentifier) ?? "CCCCCC"
        arr.append(ScheduleComponent(title: event.title, comptype: .event, startDate: event.startDate, endDate: event.endDate, colorCode: colorCode))
    }
    return arr
}

struct ScheduleView: View {
    @EnvironmentObject var timetableData: TimetableData
    @EnvironmentObject var calendarManager: CalendarManager
    @Binding var date: Date
    
    var body: some View {
        NavigationStack {
            Text("\(date)")
            ScrollView {
                ForEach(createScheduleArray(date: date, timetableArray: timetableData.timetableArray, eventArray: calendarManager.dayEvents ?? [])) { comp in
                    if comp.comptype == .subject {
                        NavigationLink(destination: TimetableView()) {
                            SubjectComponentView(component: comp)
                        }
                    } else if comp.comptype == .event {
                        Text("\(comp.title)")
                    }
                }
            }
        }
    }
}
