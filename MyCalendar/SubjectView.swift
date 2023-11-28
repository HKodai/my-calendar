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
    var colorCode = "FFFFFF"
    var noClass: Set<Date> = []
    var note = ""
}

func rgbDecode(code: String) -> Array<Double> {
    var res: Array<Double> = []
    for i in 0..<3 {
        let from = code.index(code.startIndex, offsetBy: i*2)
        let to = code.index(from, offsetBy: 1)
        res.append(Double(Int(code[from...to], radix: 16)!)/255.0)
    }
    return res
}

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
                    let rgb = rgbDecode(code: subject.colorCode)
                    Color(red: rgb[0], green: rgb[1], blue: rgb[2])
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
