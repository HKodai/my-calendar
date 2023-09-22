//
//  CalendarView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/25.
//

import SwiftUI
import EventKit

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
                    Color(red: 224/255.0, green: 197/255.0, blue: 200/255.0)
                }
            }
        } else {
            Color(.gray)
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var eventManager: EventManager
    let grids = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    let cellWidth = UIScreen.main.bounds.width/7.0
    @State var showingMonth = Date()
    @State var cells = 4
    @State var calendarDates = [CalendarDate]()
    var showingMonthString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyy/MM"
        return df.string(from: showingMonth)
    }
    func createCalendarDates() {
        cells = 4
        calendarDates = [CalendarDate]()
        let startOfMonth = calendar.startOfMonth(for: showingMonth)!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let daysInMonth = calendar.daysInMonth(for: showingMonth)!
        for day in 0..<daysInMonth {
            calendarDates.append(CalendarDate(date: calendar.date(byAdding: .day, value: day, to: startOfMonth), cells: cells))
        }
        
        if let events = eventManager.events {
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
    
    var body: some View {
        NavigationStack {
            VStack {
                Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow {
                        ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                            Text(weekday)
                                .frame(width: cellWidth)
                        }
                    }
                }
                ScrollView {
                    let height = CGFloat((cells+1)*20)
                    let weeks = calendarDates.count/7
                    ZStack {
                        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                            ForEach(0..<weeks, id: \.self) {week in
                                GridRow {
                                    ForEach(0..<7) {weekday in
                                        let index = week*7+weekday
                                        CalendarCellView(cellDate: calendarDates[index])
                                            .frame(width: cellWidth, height: height)
                                            .border(.black)
                                    }
                                }
                            }
                        }
                        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                            ForEach(0..<weeks, id: \.self) { week in
                                GridRow {
                                    ForEach(0..<7) {weekday in
                                        let index = week*7+weekday
                                        if let date = calendarDates[index].date {
                                            let day = calendar.day(for: date)!
                                            Text("\(day)")
                                                .frame(width: cellWidth, height: 20)
                                        } else {
                                            Text("")
                                                .frame(width: cellWidth, height: 20)
                                        }
                                    }
                                }
                                ForEach(0..<cells, id: \.self) { cellNumber in
                                    GridRow {
                                        ForEach(0..<7) {weekday in
                                            let index = week*7+weekday
                                            if let cellData = calendarDates[index].eventCells[cellNumber] {
                                                if weekday == 0 || cellData.isStartDay {
                                                    let columns = min(cellData.length, 7-weekday)
                                                    let width = cellWidth*Double(columns)
                                                    ZStack {
                                                        Rectangle()
                                                            .foregroundColor(.blue)
                                                        Text("\(cellData.event.title)")
                                                    }
                                                    .frame(width: width, height: 20)
                                                    .gridCellColumns(columns)
                                                }
                                            } else {
                                                Text("")
                                                    .frame(width: cellWidth, height: 20)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .onAppear{
                createCalendarDates()
            }
            .navigationBarTitle(showingMonthString, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingMonth = calendar.date(byAdding: .month, value: -1, to: showingMonth)!
                        eventManager.day = showingMonth
                        eventManager.fetchEvent()
                        createCalendarDates()
                    }) {
                        Image(systemName: "arrowtriangle.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMonth = calendar.date(byAdding: .month, value: 1, to: showingMonth)!
                        eventManager.day = showingMonth
                        eventManager.fetchEvent()
                        createCalendarDates()
                    }) {
                        Image(systemName: "arrowtriangle.right")
                    }
                }
            }
        }
    }
}
