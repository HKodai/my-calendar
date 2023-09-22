//
//  EventManager.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/09/22.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    var store = EKEventStore()
    @Published var statusMessage = ""
    @Published var events: [EKEvent]? = nil
    @Published var day = Date()
    
    init() {
        Task {
            do {
                try await store.requestAccess(to: .event)
            } catch {
                print(error.localizedDescription)
            }
            let status = EKEventStore.authorizationStatus(for: .event)
            switch status {
            case .notDetermined:
                statusMessage = "カレンダーへのアクセスする\n権限が選択されていません。"
            case .restricted:
                statusMessage = "カレンダーへのアクセスする\n権限がありません。"
            case .denied:
                statusMessage = "カレンダーへのアクセスが\n明示的に拒否されています。"
            case.authorized:
                statusMessage = "カレンダーへのアクセスが\n許可されています。"
                fetchEvent()
                NotificationCenter.default.addObserver(self, selector:#selector(fetchEvent) , name: .EKEventStoreChanged, object: store)
            @unknown default:
                statusMessage = "@unknown default"
            }
        }
    }
    
    @objc func fetchEvent() {
        let start = calendar.startOfMonth(for: day)!
        let end = calendar.startOfMonth(for: calendar.date(byAdding: .month, value: 1, to: day)!)!
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        events = store.events(matching: predicate)
    }
}
