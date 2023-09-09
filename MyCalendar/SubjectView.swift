//
//  SubjectView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/22.
//

import SwiftUI

struct Subject: Codable {
    var title = ""
    var teacher = ""
    var place = ""
    var colorNum = 0
}

let colorArray: [Color] = [.white, .blue, .green, .orange, .pink]

struct SubjectView: View {
    @EnvironmentObject var timetableData: TimetableData
    @Binding var subject: Subject
    @State var showingSheet = false
    @State var title = ""
    @State var teacher = ""
    @State var place = ""
    @State var colorNum = 0
    let day: Int
    let period: Int
    
    var body: some View {
        Button(action: {
            title = subject.title
            teacher = subject.teacher
            place = subject.place
            colorNum = subject.colorNum
            showingSheet.toggle()
        }) {
            ZStack {
                colorArray[subject.colorNum]
                VStack{
                    Spacer()
                    Text(subject.title)
                        .font(.footnote)
                        .bold()
                    Spacer()
                    Text(subject.teacher)
                        .font(.caption2)
                    Spacer()
                    Text(subject.place)
                        .font(.caption2)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            subject = Subject(title: self.title, teacher: self.teacher, place: self.place, colorNum: self.colorNum)
            timetableData.save()
        }){
            SubjectSettingView(settingTitle: $title, settingTeacher: $teacher, settingPlace: $place, settingColorNum: $colorNum, day: self.day, period: self.period)
        }
        .buttonStyle(.plain)
    }
}
