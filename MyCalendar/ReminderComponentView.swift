//
//  ReminderComponentView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/12/29.
//

import SwiftUI

struct ReminderComponentView: View {
    let component: ScheduleComponent
    
    var body: some View {
        ZStack {
            let rgb = rgbDecode(code: component.colorCode!)
            let color = Color(red: rgb[0], green: rgb[1], blue: rgb[2])
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 2)
            VStack {
                let time = component.startDate
                Text(timeFormat(comps: calendar.dateComponents([.hour, .minute], from: time)))
                Text("\(component.title)")
            }
            .foregroundStyle(color)
        }
        .frame(height: 75)
        .padding([.top, .leading, .trailing])
    }
}
