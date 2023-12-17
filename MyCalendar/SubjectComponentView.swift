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
        NavigationStack {
            NavigationLink(destination: TimetableView()) {
                ZStack {
                    let rgb = rgbDecode(code: component.colorCode!)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: rgb[0], green: rgb[1], blue: rgb[2]))
                        .frame(height: 20)
                        .padding()
                    VStack {
                        Text("\(component.title)")
                        HStack {
                            if let start = component.startDate {
                                Text("")
                            }
                        }
                    }
                }
            }
        }
    }
}
