//
//  DateSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/07.
//

import SwiftUI

func dateString(date: Date?) -> String {
    if let d = date {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ja_JP")
        df.dateStyle = .medium
        return df.string(from: d)
    } else {
        return "未設定"
    }
}

struct DateSettingView: View {
    @Binding var date: Date?
    @State var isShowDatePicker = false
    
    var body: some View {
        Button(dateString(date: date)) {
            if date == nil {
                date = Date()
            }
            isShowDatePicker.toggle()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowDatePicker) {
            VStack {
                HStack{
                    Spacer()
                    Button("完了") {
                        isShowDatePicker.toggle()
                    }
                    .padding(.trailing)
                }
                DatePicker(selection: Binding<Date>(
                    get: {date ?? Date()},
                    set: {date = $0}
                ), displayedComponents: .date, label: {})
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .datePickerStyle(.graphical)
            }
        }
    }
}
