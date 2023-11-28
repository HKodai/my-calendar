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
    var noClass: Set<Date> = []
    var note = ""
}

let colorArray: [Color] = [.white, .blue, .green, .orange, .pink]

struct SubjectView: View {
    @EnvironmentObject var timetableData: TimetableData
    @Binding var subject: Subject?
    @State var showingSheet = false
    let day: Int
    let period: Int
    
    var body: some View {
        Button(action: {
            showingSheet.toggle()
        }) {
            ZStack {
                if let subject = subject {
                    colorArray[subject.colorNum].opacity(0.5)
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
                } else {
                    Color.gray.opacity(0.5)
                }
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            timetableData.save()
        }){
            SubjectSettingView(subject: $subject, weekday: day, period: period)
        }
        .buttonStyle(.plain)
    }
}
