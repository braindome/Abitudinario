//
//  Day.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import FirebaseFirestoreSwift

struct Day : Codable, Identifiable {
    var id : String
    var habit : Habit
    var date : Date
    
    init(date: Date, habit: Habit) {
        self.date = date

        // Use DateFormatter to create a unique identifier based on date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.id = formatter.string(from: date)
        
        self.habit = habit
    }
}
