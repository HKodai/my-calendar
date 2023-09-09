//
//  TimetableSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/27.
//

import SwiftUI

struct TimetableSettingView: View {
    @EnvironmentObject var timetableData: TimetableData
    @State var settingTimetable: Timetable
    
    var body: some View {
        NavigationView{
            Form{
                // ここがTextFieldであることをわかりやすくする
                TextField("時間割の名前", text: $settingTimetable.title)
                HStack {
                    Text("開始日")
                    Spacer()
                    DateSettingView(date: $settingTimetable.startDate)
                }
                HStack {
                    Text("終了日")
                    Spacer()
                    DateSettingView(date: $settingTimetable.endDate)
                }
                DisclosureGroup("曜日の設定") {
                    ForEach(0..<7) {dayNum in
                        Toggle(weekDayStringArray[dayNum], isOn: $settingTimetable.weekDays[dayNum])
                    }
                }
                DisclosureGroup("時限の設定") {
                    ForEach(0..<settingTimetable.showingPeriods, id: \.self) { periodNum in
                        HStack{
                            Text("\(periodNum+1)限")
                            Spacer()
                            PeriodSettingView(period: $settingTimetable.periods[periodNum])
                        }
                    }
                    HStack {
                        Spacer()
                        if settingTimetable.showingPeriods > 1 {
                            Button(action:{
                                settingTimetable.showingPeriods -= 1
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: "minus.circle")
                        }
                        Spacer()
                        Button(action: {
                            settingTimetable.showingPeriods += 1
                            if settingTimetable.periods.count < settingTimetable.showingPeriods {
                                settingTimetable.periods.append(Period(startTime: DateComponents(), endTime: DateComponents()))
                            }
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("時間割の設定")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let old = settingTimetable.table[0].count
                    let new = settingTimetable.showingPeriods
                    if old < new {
                        for dayNum in 0..<7 {
                            for _ in 0..<new-old {
                                settingTimetable.table[dayNum].append(Subject())
                            }
                        }
                    }
                    timetableData.currentTimetable = settingTimetable
                    timetableData.save()
                }) {
                    Text("保存")
                }
            }
        }
    }
}
