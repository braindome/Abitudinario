//
//  HabitTrackerViewModel.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation
import SwiftUI
import Firebase
import UIKit

class HabitTrackerViewModel : ObservableObject {
    
    @Published var selectedDate = Date()
    @Published var habits = [Habit]()

    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    
    func addHabitToFirestore(habitName: String, habitDesc: String, date: Date, dailyReminder: Date) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits")
        let habit = Habit(name: habitName, description: habitDesc, date: date, completedDates: [], dailyReminder: dailyReminder)
        
        do {
            print("Adding habit \(habitName) to firebase")
            try habitsRef.addDocument(from: habit)
        } catch {
            print("Error saving to database")
        }
    }
    
    func listenToFirebase() {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits")
        
        habitsRef.addSnapshotListener() { snapshot, err in
            guard let snapshot = snapshot else {return}
            
            if let err = err {
                print("error getting document \(err)")
            } else {
                self.habits.removeAll()
                for document in snapshot.documents {
                    
                    do {
                        let habit = try document.data(as: Habit.self)
                        self.habits.append(habit)
                    } catch {
                        //print("listenToFirebase - Error reading from db")
                        print("Error decoding habit: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func delete(index: Int) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits")
        
        let habit = habits[index]
        if let id = habit.docId {
            habitsRef.document(id).delete()
        }
    }
    
    func toggle(habit: Habit, latestDone: Date) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits")
        let isHabitCompleted = isHabitCompletedOnDate(habit: habit, date: latestDone)
        
        var updatedCompletedDates = habit.completedDates
        if isHabitCompleted {
            updatedCompletedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: latestDone) }
        } else {
            updatedCompletedDates.append(latestDone)
        }
        


        if let docId = habit.docId {
            let updatedHabit = Habit(
                name: habit.name,
                description: habit.description,
                date: habit.date,
                completedDates: updatedCompletedDates,
                dailyReminder: habit.dailyReminder
            )

            do {
                try habitsRef.document(docId).setData(from: updatedHabit)
            } catch {
                print("Error updating habit: \(error.localizedDescription)")
            }
        }
        
        let streak = calculateCurrentStreak(from: updatedCompletedDates)
        print("Current streak: \(streak)")
        
        if let docId = habit.docId {
            let newData = ["currentStreak": streak]
            let docRef = habitsRef.document(docId)
            docRef.setData(newData, merge: true) { error in
                if let error = error {
                    print("Error updating habit with streak: \(error)")
                } else {
                    print("Successfully updated habit with streak")
                }
            }
        }


    }
    
    
    
    // ----------------- STREAK ---------------------
    func testCalculateCurrentStreak() {
        let habitViewModel = HabitTrackerViewModel()

        // Test Case 1: Completed yesterday and today
        let completedDates1 = [
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Date()
        ]
        let currentStreak1 = habitViewModel.calculateCurrentStreak(from: completedDates1)
        print("Test Case 1: Completed yesterday and today")
        print("Expected Streak: 2, Actual Streak: \(currentStreak1)")

        // Test Case 2: Completed yesterday and tomorrow
        let completedDates2 = [
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        ]
        let currentStreak2 = habitViewModel.calculateCurrentStreak(from: completedDates2)
        print("Test Case 2: Completed yesterday and tomorrow")
        print("Expected Streak: 1, Actual Streak: \(currentStreak2)")

        // Test Case 3: Completed on three consecutive days, including today
        let completedDates3 = [
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Date()
        ]
        let currentStreak3 = habitViewModel.calculateCurrentStreak(from: completedDates3)
        print("Test Case 3: Completed on three consecutive days, including today")
        print("Expected Streak: 3, Actual Streak: \(currentStreak3)")

        // Test Case 4: Completed two days ago, yesterday, and tomorrow
        let completedDates4 = [
            Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        ]
        let currentStreak4 = habitViewModel.calculateCurrentStreak(from: completedDates4)
        print("Test Case 4: Completed two days ago, yesterday, and tomorrow")
        print("Expected Streak: 2, Actual Streak: \(currentStreak4)")
    }
    
    func calculateCurrentStreak(from completedDates: [Date]) -> Int {
        var currentStreak = 0

        // Sort the completed dates in ascending order
        let sortedDates = completedDates.sorted()

        // Start with the most recent completed date and check if the previous date is one day before
        for i in (0..<sortedDates.count).reversed() {
            // Skip future dates
            if Calendar.current.compare(sortedDates[i], to: Date(), toGranularity: .day) == .orderedDescending {
                continue
            }

            if i == sortedDates.count - 1 || Calendar.current.compare(sortedDates[i + 1], to: Date(), toGranularity: .day) == .orderedDescending {
                // The most recent completed date is today, or the next date is in the future, so the streak is at least 1
                currentStreak = 1
            } else {
                let previousDate = sortedDates[i]
                let currentDate = sortedDates[i + 1]
                let components = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate)
                if let days = components.day, days == 1 {
                    // The previous date is one day before the current date, so increase the streak count
                    currentStreak += 1
                } else {
                    // The streak is broken, so exit the loop
                    break
                }
            }
        }

        return currentStreak
    }
    
    
    func isHabitCompletedOnDate(habit: Habit, date: Date) -> Bool {
        return habit.completedDates.contains { completedDate in
            return Calendar.current.isDate(completedDate, inSameDayAs: date)
        }
    }
}
