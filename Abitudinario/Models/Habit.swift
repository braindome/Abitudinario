//
//  Habit.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import FirebaseFirestoreSwift

struct Habit : Codable, Identifiable {
    @DocumentID var docId : String?
    var name : String
    var description : String
    var isCompleted : Bool = false
    var date : Date?
    var currentStreak : Int = 0
    var latestDone : Date?
    var completedDates : [Date] = []
    var dailyReminder : Date?
    var id : String {
        return docId ?? UUID().uuidString
    }
}
