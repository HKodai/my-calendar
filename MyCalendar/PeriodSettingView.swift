//
//  PeriodSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/07.
//

import SwiftUI

func timeString(time: DateComponents) -> String {
    if let hour = time.hour,
       let minute = time.minute {
        return String(hour)+":"+String(format: "%02d",minute)
    } else {
        return "未設定"
    }
}

struct PeriodSettingView: View {
    @Binding var  period: Period
    @State var isShowPicker = false
    
    var body: some View {
        Button(timeString(time: period.startTime)+" ~ "+timeString(time: period.endTime)) {
            isShowPicker.toggle()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isShowPicker) {
            VStack{
                HStack{
                    Spacer()
                    Button("完了") {
                        isShowPicker.toggle()
                    }
                    .padding(.trailing)
                }
                HStack{
                    Picker(selection: $period.startTime.hour) {
                        Text("")
                            .tag(Int?(nil))
                        ForEach(0..<24, id: \.self) { num in
                            Text(String(num))
                                .tag(Optional(num))
                        }
                    } label: {
                        Text("開始時")
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75)
                    .clipped()
                    Text(":")
                    Picker(selection: $period.startTime.minute) {
                        Text("")
                            .tag(Int?(nil))
                        ForEach(0..<60, id: \.self) { num in
                            Text(String(format: "%02d", num))
                                .tag(Optional(num))
                        }
                    } label: {
                        Text("開始分")
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75)
                    .clipped()
                    Text("~")
                    Picker(selection: $period.endTime.hour) {
                        Text("")
                            .tag(Int?(nil))
                        ForEach(0..<24, id: \.self) { num in
                            Text(String(num))
                                .tag(Optional(num))
                        }
                    } label: {
                        Text("終了時")
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75)
                    .clipped()
                    Text(":")
                    Picker(selection: $period.endTime.minute) {
                        Text("")
                            .tag(Int?(nil))
                        ForEach(0..<60, id: \.self) { num in
                            Text(String(format: "%02d", num))
                                .tag(Optional(num))
                        }
                    } label: {
                        Text("終了分")
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 75)
                    .clipped()
                }
            }
            .presentationDetents([.medium])
        }
    }
}
