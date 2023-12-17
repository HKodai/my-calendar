//
//  ScheduleComponentView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/12/17.
//

import SwiftUI

struct SubjectComponentView: View {
    let component: ScheduleComponent
    
    var body: some View {
        ZStack {
            let rgb = rgbDecode(code: component.colorCode!)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: rgb[0], green: rgb[1], blue: rgb[2]))
                .frame(height: 75)
                .padding()
            VStack {
                HStack {
                    if let start = component.startDate {
                        Text(timeFormat(comps: calendar.dateComponents([.hour, .minute], from: start)))
                    }
                    if component.startDate != nil || component.endDate != nil {
                        Text("~")
                    }
                    if let end = component.endDate {
                        Text(timeFormat(comps: calendar.dateComponents([.hour, .minute], from: end)))
                    }
                }
                Text("\(component.title)")
            }
        }
    }
}
