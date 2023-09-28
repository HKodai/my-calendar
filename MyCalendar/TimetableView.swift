//
//  TimetableView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/22.
//

import SwiftUI

struct Period: Codable {
    var startTime: DateComponents
    var endTime: DateComponents
}

struct Timetable: Codable {
    var title: String = "時間割"
    var startDate: Date? = nil
    var endDate: Date? = nil
    var weekDays: [Bool] = [false, true, true, true, true, true, false]
    var showingPeriods: Int = 5
    var periods: [Period] = Array(repeating: Period(startTime: DateComponents(), endTime: DateComponents()), count: 5)
    var table: [[Subject?]] = Array(repeating: Array(repeating: nil, count: 5), count: 7)
}

class TimetableData: ObservableObject {
    @Published var timetableArray: [Timetable] = [Timetable()]
    @Published var currentTimetableIndex: Int
    var currentTimetable: Timetable {
        get {
            timetableArray[currentTimetableIndex]
        }
        set(value) {
            timetableArray[currentTimetableIndex] = value
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "timetableArray"),
           let savedTimetableArray = try? JSONDecoder().decode([Timetable].self, from: data){
            timetableArray = savedTimetableArray
        }
        currentTimetableIndex = UserDefaults.standard.integer(forKey: "currentTimetableIndex")
    }
    
    func save() {
        if let encodeData = try? JSONEncoder().encode(timetableArray) {
            UserDefaults.standard.set(encodeData, forKey: "timetableArray")
        }
        UserDefaults.standard.set(currentTimetableIndex, forKey: "currentTimetableIndex")
    }
}

struct TimetableView: View {
    @EnvironmentObject var timetableData: TimetableData
    let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(.white)
                ScrollView {
                    Grid(horizontalSpacing: 1, verticalSpacing: 1){
                        GridRow{
                            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
                                .padding(.horizontal)
                            ForEach(0..<7) { day in
                                if timetableData.currentTimetable.weekDays[day] == true{
                                    Text(calendar.shortWeekdaySymbols[day])
                                        .font(.headline)
                                }
                            }
                        }
                        ForEach(0..<timetableData.currentTimetable.showingPeriods, id: \.self) { periodNum in
                            GridRow{
                                VStack{
                                    let periodTime = timetableData.currentTimetable.periods[periodNum]
                                    if let startHour = periodTime.startTime.hour,
                                       let startMinute = periodTime.startTime.minute {
                                        Text(String(startHour)+":"+String(format: "%02d",startMinute))
                                            .font(.footnote)
                                    }
                                    Text(String(periodNum+1))
                                        .font(.headline)
                                        .padding(.vertical, 1)
                                    if let endHour = periodTime.endTime.hour,
                                       let endMinute = periodTime.endTime.minute {
                                        Text(String(endHour)+":"+String(format: "%02d", endMinute))
                                            .font(.footnote)
                                    }
                                }
                                ForEach(0..<7) { dayNum in
                                    if timetableData.currentTimetable.weekDays[dayNum] == true{
                                        SubjectView(subject: $timetableData.currentTimetable.table[dayNum][periodNum], day: dayNum, period: periodNum)
                                            .frame(height: 100)
                                            .border(Color.black)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(timetableData.currentTimetable.title, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        TimetableSelectView()
                    } label: {
                        Image(systemName: "square.on.square")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        TimetableAddView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink{
                        TimetableSettingView(settingTimetable: timetableData.currentTimetable)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
