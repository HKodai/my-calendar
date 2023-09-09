//
//  MyCalendarApp.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/08/22.
//

import SwiftUI

@main
struct MyCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TimetableData())
        }
    }
}
