//
//  CreateReminderView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/26.
//

import SwiftUI

struct CreateReminderView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @State var dueDate = Date()
    @State var hasDueDate = false
    @State var isError = false
    
    var body: some View {
        NavigationStack {
            List {
                TextField("タイトル", text: $title)
                Toggle("終了日を設定", isOn: $hasDueDate)
                if hasDueDate {
                    DatePicker("終了日", selection: $dueDate)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        if title == "" {
                            isError.toggle()
                        } else {
                            if hasDueDate {
                                calendarManager.createReminder(title: title, dueDate: dueDate)
                            } else {
                                calendarManager.createReminder(title: title, dueDate: nil)
                            }
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
    }
}
