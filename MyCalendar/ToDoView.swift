//
//  ToDoView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/25.
//

import SwiftUI
import EventKit

struct ToDoView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State var isShowCreateReminderView = false
    @State var reminder: EKReminder?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(calendarManager.allReminders ?? [], id: \.self) {reminder in
                Button("\(reminder.title)") {
                    self.reminder = reminder
                    isShowCreateReminderView = true
                }
            }
            Button(action: {
                reminder = nil
                isShowCreateReminderView.toggle()
            }, label: {
                ZStack {
                    Circle()
                        .frame(width: 50, height: 100)
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
                .padding()
            })
        }
        .sheet(isPresented: $isShowCreateReminderView) {
            CreateReminderView(reminder: $reminder)
        }
        .onAppear{
            calendarManager.fetchAllReminder()
        }
    }
}
