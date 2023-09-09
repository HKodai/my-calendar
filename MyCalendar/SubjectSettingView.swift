//
//  SubjectSettingView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/23.
//

import SwiftUI

struct SubjectSettingView: View {
    @Binding var settingTitle: String
    @Binding var settingTeacher: String
    @Binding var settingPlace: String
    @Binding var settingColorNum: Int
    let day: Int
    let period: Int

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
            }
            .navigationTitle(weekDayStringArray[day]+"曜"+String(period+1)+"限")
        }
    }
}
