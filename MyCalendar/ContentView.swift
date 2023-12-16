//
//  ContentView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/22.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTag = 2
    var body: some View {
        TabView(selection: $selectedTag) {
            TimetableView()
                .tabItem{
                    Label("時間割", systemImage: "tablecells")
                }
                .tag(1)
            CalendarView()
                .tabItem{
                    Label("カレンダー", systemImage: "calendar")
                }.tag(2)
            ReminderView()
                .tabItem{
                    Label("リマインダー", systemImage: "list.clipboard")
                }.tag(3)
        }
    }
}
