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
    
    let colors = ["FFFFFF", "CCCCFF", "CCFFCC", "CCFFFF", "FFCCCC", "FFCCFF", "FFFFCC"]
    
    var body: some View {
        NavigationView {
            Form {
                TextField("科目", text: $tempSubject.title)
                TextField("教員", text: $tempSubject.teacher)
                TextField("場所", text: $tempSubject.place)
                ColorSelectView(selectedColor: $tempSubject.colorCode, colors: colors, diameter: 36)
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
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $tempSubject.note)
                        .padding(.horizontal, -4)
                        .frame(minHeight: 200)
                    if tempSubject.note.isEmpty {
                        Text("メモ").foregroundStyle(Color(uiColor: UIColor.placeholderText))
                            .padding(.vertical, 8)
                            .allowsHitTesting(false)
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
