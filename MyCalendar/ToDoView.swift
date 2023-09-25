//
//  ToDoView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/25.
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    
    var body: some View {
        VStack {
            ForEach(calendarManager.allReminders ?? [], id: \.self) {reminder in
                Text("\(reminder.title)")
            }
        }
        .onAppear{
            calendarManager.fetchAllReminder()
        }
    }
}
