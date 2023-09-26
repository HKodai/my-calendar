//
//  ToDoView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/25.
//

import SwiftUI

struct ToDoView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State var isShowCreateReminderView = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(calendarManager.allReminders ?? [], id: \.self) {reminder in
                Text("\(reminder.title)")
            }
            Button(action: {
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
            CreateReminderView()
        }
        .onAppear{
            calendarManager.fetchAllReminder()
        }
    }
}
