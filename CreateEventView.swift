//
//  CreateEventView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/11/28.
//

import SwiftUI
import EventKit

struct CreateEventView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    @Binding var event: EKEvent?
    @State var title = ""
    @State var start = Date()
    @State var end = Date()
    @State var isError = false
    
    var body: some View {
        NavigationStack {
            List {
                TextField("タイトル", text: $title)
                DatePicker("開始", selection: $start)
                DatePicker("終了", selection: $end, in: start...)
                    .onChange(of: start) { newValue in
                        if start > end {
                            end = start
                        }
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(event == nil ? "追加" : "変更") {
                        if title == "" {
                            isError.toggle()
                        } else {
                            calendarManager.createEvent(title: title, startDate: start, endDate: end)
                            dismiss()
                        }
                    }
                    .alert(isPresented: $isError) {
                        Alert(title: Text("タイトルを入力してください"), dismissButton: .default(Text("OK")))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", role: .destructive) {
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .task {
            if let event {
                self.title = event.title
                self.start = event.startDate
                self.end = event.endDate
            }
        }
    }
}
