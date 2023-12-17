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

struct ScheduleComponent {
    let title: String
    let comptype: ScheduleCompType
    let startDate: Date?
    let endDate: Date?
    let colorCode: String?
}

func createScheduleArray(date: Date, timetableArray: [Timetable]) -> [ScheduleComponent] {
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
    return arr
}

struct ScheduleView: View {
    @EnvironmentObject var timetableData: TimetableData
    @Binding var date: Date
    
    var body: some View {
        Text("\(date)")
        Button("ボタン", action: {
            print(createScheduleArray(date: date, timetableArray: timetableData.timetableArray))
        })
    }
}
