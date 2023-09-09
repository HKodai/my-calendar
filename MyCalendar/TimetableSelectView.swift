//
//  TimetableSelectView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/08.
//

import SwiftUI

struct TimetableSelectView: View {
    @EnvironmentObject var timetableData: TimetableData
    
    var body: some View {
        NavigationView{
            List {
                ForEach(timetableData.timetableArray.indices, id: \.self) { index in
                    HStack {
                        if index == timetableData.currentTimetableIndex {
                            Image(systemName: "bookmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        } else {
                            Button(action: {
                                if index < timetableData.currentTimetableIndex {
                                    timetableData.currentTimetableIndex -= 1
                                }
                                timetableData.timetableArray.remove(at: index)
                                timetableData.save()
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.plain)
                        }
                        Button(timetableData.timetableArray[index].title) {
                            timetableData.currentTimetableIndex = index
                            timetableData.save()
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("時間割の選択・削除")
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
