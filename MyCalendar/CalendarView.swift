//
//  CalendarView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/25.
//

import SwiftUI

extension Calendar {
    func startOfMonth(for date: Date) -> Date? {
        let comps = dateComponents([.month, .year], from: date)
        return self.date(from: comps)
    }
    func daysInMonth(for date: Date) -> Int? {
        return range(of: .day, in: .month, for: date)?.count
    }
    func weekInMonth(for date: Date) -> Int? {
        return range(of: .weekOfMonth, in: .month, for: date)?.count
    }
    func year(for date: Date) -> Int? {
        let comps = dateComponents([.year], from: date)
        return comps.year
    }
    func month(for date: Date) -> Int? {
        let comps = dateComponents([.month], from: date)
        return comps.month
    }
    func day(for date: Date) -> Int? {
        let comps = dateComponents([.day], from: date)
        return comps.day
    }
    func weekday(for date: Date) -> Int? {
        let comps = dateComponents([.weekday], from: date)
        return comps.weekday
    }
}

// currentは怖い。後で検討
var calendar: Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "ja_JP")
    return cal
}

func isClassDate(array: [Timetable], date: Date) -> Bool {
    let weekday = calendar.weekday(for: date)!-1
    for timetable in array {
        if let start = timetable.startDate,
           let end = timetable.endDate {
            if calendar.startOfDay(for: start) <= date && date <= end && timetable.weekDays[weekday] {
                for period in 0..<timetable.showingPeriods {
                    if !timetable.table[weekday][period].noClass.contains(date) {
                        return true
                    }
                }
            }
        }
    }
    return false
}

struct EventCell {
    let title = ""
    let color = Color.clear
    let length = 1
}

struct CalendarDate: Identifiable {
    let id = UUID()
    let date: Date?
    var eventCells = [EventCell]()
}

func createCalendarDates(_ date: Date) -> [CalendarDate] {
    var days = [CalendarDate]()
    let startOfMonth = calendar.startOfMonth(for: date)
    let daysInMonth = calendar.daysInMonth(for: date)
    guard let daysInMonth = daysInMonth,
          let startOfMonth = startOfMonth
    else {return []}
    for day in 0..<daysInMonth {
        days.append(CalendarDate(date: calendar.date(byAdding: .day, value: day, to: startOfMonth)))
    }
    guard let firstDay = days.first,
          let lastDay = days.last,
          let firstDate = firstDay.date,
          let lastDate = lastDay.date,
          let firstDateWeekday = calendar.weekday(for: firstDate),
          let lastDateWeekday = calendar.weekday(for: lastDate)
    else{return []}
    let firstWeekEmptyDays = firstDateWeekday - 1
    let lastWeekEmptyDays = 7 - lastDateWeekday
    for _ in 0..<firstWeekEmptyDays {
        days.insert(CalendarDate(date: nil), at: 0)
    }
    for _ in 0..<lastWeekEmptyDays {
        days.append(CalendarDate(date: nil))
    }
    return days
}

struct CalendarCellView: View {
    @EnvironmentObject var timetableData: TimetableData
    let today = Date()
    let cellDate: CalendarDate
    
    var body: some View {
        if let date = cellDate.date {
            ZStack {
                if isClassDate(array: timetableData.timetableArray, date: date) {
                    Color(.white)
                } else {
                    Color(red: 224/255, green: 197/255, blue: 200/255)
                }
                VStack {
                    let day = calendar.day(for: date)!
                    if calendar.isDate(date, inSameDayAs: today) {
                        Text("\(day)")
                            .foregroundColor(.blue)
                    } else {
                        Text("\(day)")
                    }
                    Spacer()
                }
            }
        } else {
            Color(.gray)
        }
    }
}

struct CalendarView: View {
    let grids = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    @State var showingMonth = Date()
    var calendarDates: [CalendarDate] {
        return createCalendarDates(showingMonth)
    }
    var showingMonthString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyy/MM"
        return df.string(from: showingMonth)
    }
    var body: some View {
        NavigationStack {
            VStack {
                LazyVGrid(columns: grids) {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) {weekday in
                        Text(weekday)
                    }
                }
                ScrollView {
                    let rows = max(5, calendarDates.first!.eventCells.count+1)
                    let height = CGFloat(rows*20)
                    LazyVGrid(columns: grids, spacing: 0) {
                        ForEach(calendarDates) { date in
                            CalendarCellView(cellDate: date)
                                .frame(height: height)
                                .border(.black)
                        }
                    }
                }
            }
            .navigationBarTitle(showingMonthString, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingMonth = calendar.date(byAdding: .month, value: -1, to: showingMonth)!
                    }) {
                        Image(systemName: "arrowtriangle.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMonth = calendar.date(byAdding: .month, value: 1, to: showingMonth)!
                    }) {
                        Image(systemName: "arrowtriangle.right")
                    }
                }
            }
        }
    }
}
