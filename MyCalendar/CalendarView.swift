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
    func days(from date1: Date, to date2: Date) -> Int {
        let comps = dateComponents([.day], from: startOfDay(for: date1), to: startOfDay(for: date2))
        return comps.day!
    }
}

struct CalendarDate: Identifiable {
    let id = UUID()
    let date: Date?
}

func createCalendarDates(_ date: Date) -> [CalendarDate] {
    var days = [CalendarDate]()
    let startOfMonth = Calendar.current.startOfMonth(for: date)
    let daysInMonth = Calendar.current.daysInMonth(for: date)
    guard let daysInMonth = daysInMonth,
          let startOfMonth = startOfMonth
    else {return []}
    for day in 0..<daysInMonth {
        days.append(CalendarDate(date: Calendar.current.date(byAdding: .day, value: day, to: startOfMonth)))
    }
    guard let firstDay = days.first,
          let lastDay = days.last,
          let firstDate = firstDay.date,
          let lastDate = lastDay.date,
          let firstDateWeekday = Calendar.current.weekday(for: firstDate),
          let lastDateWeekday = Calendar.current.weekday(for: lastDate)
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
    let today = Date()
    let cellDate: CalendarDate
    
    var body: some View {
        if let date = cellDate.date {
            ZStack {
                let day = Calendar.current.day(for: date)!
                if Calendar.current.isDate(date, inSameDayAs: today) {
                    Color(.green)
                } else {
                    Color(.white)
                }
                VStack {
                    Text("\(day)")
                    Spacer()
                }
            }
        } else {
            Color(.gray)
        }
    }
}

struct CalendarView: View {
    let weekdays = Calendar.current.shortWeekdaySymbols
    let grids = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    @State var showingMonth = Date()
    var calendarDates: [CalendarDate] {
        return createCalendarDates(showingMonth)
    }
    var showingMonthString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM"
        return df.string(from: showingMonth)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                LazyVGrid(columns: grids) {
                    ForEach(weekdays, id: \.self) {weekday in
                        Text(weekday)
                    }
                }
                ScrollView {
                    LazyVGrid(columns: grids, spacing: 0) {
                        ForEach(calendarDates) {calendarDate in
                            CalendarCellView(cellDate: calendarDate)
                                .frame(height: 100)
                                .border(.black)
                        }
                    }
                }
            }
            .navigationBarTitle(showingMonthString, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingMonth = Calendar.current.date(byAdding: .month, value: -1, to: showingMonth)!
                    }) {
                        Image(systemName: "arrowtriangle.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingMonth = Calendar.current.date(byAdding: .month, value: 1, to: showingMonth)!
                    }) {
                        Image(systemName: "arrowtriangle.right")
                    }
                }
            }
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
