//
//  SubjectSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/23.
//

import SwiftUI

struct SubjectSettingView: View {
    @EnvironmentObject var timetableData: TimetableData
    @Binding var settingTitle: String
    @Binding var settingTeacher: String
    @Binding var settingPlace: String
    @Binding var settingColorNum: Int
    @Binding var settingNoClass: Set<Date>
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .short
        return formatter
    }()
    let weekday: Int
    let period: Int
    var scheduleArray: [Date] {
        var arr: [Date] = []
        let start = Calendar.current.startOfDay(for: timetableData.currentTimetable.startDate!)
        let end = Calendar.current.startOfDay(for: timetableData.currentTimetable.endDate!)
        let startWeekday = Calendar.current.component(.weekday, from: start)-1
        var scheduleDate = Calendar.current.date(byAdding: .day, value: (weekday+7-startWeekday)%7-7, to: start)!
        while Calendar.current.date(byAdding: .day, value: 7, to: scheduleDate)! <= end {
            scheduleDate = Calendar.current.date(byAdding: .day, value: 7, to: scheduleDate)!
            arr.append(scheduleDate)
        }
        return arr
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("科目", text: $settingTitle)
                TextField("教員", text: $settingTeacher)
                TextField("場所", text: $settingPlace)
                Picker(selection: $settingColorNum, label: Text("背景色")) {
                    Text("白").tag(0)
                    Text("青").tag(1)
                    Text("緑").tag(2)
                    Text("オレンジ").tag(3)
                    Text("ピンク").tag(4)
                }
                if let _ = timetableData.currentTimetable.startDate,
                   let _ = timetableData.currentTimetable.endDate {
                    DisclosureGroup("休講日の設定") {
                        ForEach (scheduleArray, id:\.self) { date in
                            Toggle(dateFormatter.string(from: date), isOn: Binding(
                                get: { self.settingNoClass.contains(date)},
                                set: { newValue in
                                    if newValue {
                                        self.settingNoClass.insert(date)
                                    } else {
                                        self.settingNoClass.remove(date)
                                    }
                                }))
                        }
                    }
                }
            }
            .navigationTitle(weekDayStringArray[weekday]+"曜"+String(period+1)+"限")
        }
    }
}
