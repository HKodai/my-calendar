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
                    if let subject = timetable.table[weekday][period] {
                        if !subject.noClass.contains(date) {
                            return true
                        }
                    }
                }
            }
        }
    }
    return false
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
                    Color(.systemPink).opacity(0.15)
                }
            }
        } else {
            Color(.gray).opacity(0.3)
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State var isShowCreateEventView = false
    @State var event: EKEvent? = nil
    let grids = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    let cellWidth = UIScreen.main.bounds.width/7.0
    var showingMonthString: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateFormat = "yyyy/MM"
        return df.string(from: calendarManager.showingMonth)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
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
                        let height = CGFloat((calendarManager.cells+1)*20)
                        let weeks = calendarManager.calendarDates.count/7
                        ZStack {
                            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                                ForEach(0..<weeks, id: \.self) {week in
                                    GridRow {
                                        ForEach(0..<7) {weekday in
                                            let index = week*7+weekday
                                            let cellDate = calendarManager.calendarDates[index]
                                            // 今日なら枠線を青くする
                                            if cellDate.date != nil && calendar.isDate(cellDate.date!, inSameDayAs: Date()) {
                                                CalendarCellView(cellDate: calendarManager.calendarDates[index])
                                                    .frame(width: cellWidth, height: height)
                                                    .border(.blue, width: 3)
                                            } else {
                                                CalendarCellView(cellDate: calendarManager.calendarDates[index])
                                                    .frame(width: cellWidth, height: height)
                                                    .border(.black)
                                            }
                                        }
                                    }
                                }
                            }
                            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                                // 週ごとに処理
                                ForEach(0..<weeks, id: \.self) { week in
                                    // 1行目に日付を表示
                                    GridRow {
                                        ForEach(0..<7) {weekday in
                                            let index = week*7+weekday
                                            if let date = calendarManager.calendarDates[index].date {
                                                let day = calendar.day(for: date)!
                                                Text("\(day)")
                                                    .frame(width: cellWidth, height: 20)
                                            } else {
                                                Text("")
                                                    .frame(width: cellWidth, height: 20)
                                            }
                                        }
                                    }
                                    // イベントかリマインダーがあれば上から詰めて表示
                                    ForEach(0..<calendarManager.cells, id: \.self) { cellNumber in
                                        GridRow {
                                            ForEach(0..<7) {weekday in
                                                let index = week*7+weekday
                                                //                                            セルに何か入っている場合
                                                if let cellData = calendarManager.calendarDates[index].eventReminderCells[cellNumber] {
                                                    //                                                中身がイベントの場合
                                                    if let event = cellData.event {
                                                        if weekday == 0 || cellData.isStartDay {
                                                            let columns = min(cellData.length, 7-weekday)
                                                            let width = cellWidth*Double(columns)-2
                                                            ZStack {
                                                                let colorCode = UserDefaults.standard.string(forKey: event.eventIdentifier) ?? "CCCCCC"
                                                                let rgb = rgbDecode(code: colorCode)
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .foregroundColor(Color(red: rgb[0], green: rgb[1], blue: rgb[2]))
                                                                Text("\(event.title)")
                                                                    .font(.system(size: 11))
                                                            }
                                                            .frame(width: width, height: 20)
                                                            .gridCellColumns(columns)
                                                        }
                                                    }
                                                    //                                                中身がリマインダーの場合
                                                    if let reminder = cellData.reminder {
                                                        let colorCode = UserDefaults.standard.string(forKey: reminder.calendarItemIdentifier) ?? "000000"
                                                        let rgb = rgbDecode(code: colorCode)
                                                        Text("\(reminder.title)")
                                                            .foregroundColor(Color(red: rgb[0], green: rgb[1], blue: rgb[2]))
                                                            .font(.system(size: 11))
                                                            .frame(width: cellWidth-2, height: 20)
                                                    }
                                                    //                                                セルが空の場合
                                                } else {
                                                    Text("")
                                                        .frame(width: cellWidth, height: 20)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                                ForEach(0..<weeks, id: \.self) {week in
                                    GridRow {
                                        ForEach(0..<7) {weekday in
                                            let index = week*7+weekday
                                            Button(action: {
                                                print("\(index)")
                                            }) {
                                                Color.clear
                                            }
                                            .frame(width: cellWidth, height: height)
                                        }
                                    }
                                }
                            }
                        }
                        Spacer(minLength: 100)
                    }
                }
                Button(action: {
                    isShowCreateEventView.toggle()
                }, label: {
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 100)
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                    .padding()
                })
            }
            .sheet(isPresented: $isShowCreateEventView) {
                CreateEventView(event: $event)
            }
            .onAppear{
                calendarManager.createCalendarDates()
            }
            .navigationBarTitle(showingMonthString, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        calendarManager.showingMonth = calendar.date(byAdding: .month, value: -1, to: calendarManager.showingMonth)!
                        calendarManager.createCalendarDates()
                    }) {
                        Image(systemName: "arrowtriangle.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        calendarManager.showingMonth = calendar.date(byAdding: .month, value: 1, to: calendarManager.showingMonth)!
                        calendarManager.createCalendarDates()
                    }) {
                        Image(systemName: "arrowtriangle.right")
                    }
                }
            }
        }
    }
}
