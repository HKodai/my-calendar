//
//  TimetableAddView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/08.
//

import SwiftUI

struct TimetableAddView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var timetableData: TimetableData
    
    var body: some View {
        NavigationView {
            List {
                Button("新規作成") {
                    timetableData.currentTimetableIndex = timetableData.timetableArray.count
                    timetableData.timetableArray.append(Timetable())
                    timetableData.save()
                    dismiss()
                }
                Section {
                    ForEach(timetableData.timetableArray.indices, id: \.self) { index in
                        Button(timetableData.timetableArray[index].title) {
                            var newTimetable = timetableData.timetableArray[index]
                            newTimetable.title += " - コピー"
                            timetableData.currentTimetableIndex = timetableData.timetableArray.count
                            timetableData.timetableArray.append(newTimetable)
                            timetableData.save()
                            dismiss()
                        }
                    }
                } header: {
                    Text("既存の時間割を複製")
                }
            }
        }
        .navigationTitle("時間割の追加")
        .toolbarBackground(.visible, for: .navigationBar)
    }    
}

