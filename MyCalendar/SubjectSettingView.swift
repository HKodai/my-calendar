//
//  SubjectSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/23.
//

import SwiftUI

struct SubjectSettingView: View {
    @EnvironmentObject var timetableData: TimetableData
    @Environment(\.dismiss) var dismiss
    @Binding var subject: Subject?
    @State var tempSubject = Subject()
    let weekday: Int
    let period: Int
    var scheduleArray: [Date] {
        var arr: [Date] = []
        let start = calendar.startOfDay(for: timetableData.currentTimetable.startDate!)
        let end = calendar.startOfDay(for: timetableData.currentTimetable.endDate!)
        let startWeekday = calendar.component(.weekday, from: start)-1
        var scheduleDate = calendar.date(byAdding: .day, value: (weekday+7-startWeekday)%7-7, to: start)!
        while calendar.date(byAdding: .day, value: 7, to: scheduleDate)! <= end {
            scheduleDate = calendar.date(byAdding: .day, value: 7, to: scheduleDate)!
            arr.append(scheduleDate)
        }
        return arr
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("科目", text: $tempSubject.title)
                TextField("教員", text: $tempSubject.teacher)
                TextField("場所", text: $tempSubject.place)
                Picker(selection: $tempSubject.colorNum, label: Text("背景色")) {
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
                            Toggle(dateString(date: date), isOn: Binding(
                                get: { self.tempSubject.noClass.contains(date)},
                                set: { newValue in
                                    if newValue {
                                        self.tempSubject.noClass.insert(date)
                                    } else {
                                        self.tempSubject.noClass.remove(date)
                                    }
                                }))
                        }
                    }
                }
            }
            .navigationTitle(calendar.shortWeekdaySymbols[weekday]+"曜"+String(period+1)+"限")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(subject == nil ? "追加" : "変更") {
                        subject = tempSubject
                        dismiss()
                    }
                }
                if let _ = subject {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("削除") {
                            subject = nil
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            if let subject = subject {
                tempSubject = subject
            }
        }
    }
}
