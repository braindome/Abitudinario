//
//  HabitTrackerViewModel.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation
import SwiftUI
import Firebase

class HabitTrackerViewModel : ObservableObject {
    
    @Published var selectedDate = Date()
    @Published var habits = [Habit]()

    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    
    func addHabitToFirestore(habitName: String, habitDesc: String, date: Date) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits")
        let habit = Habit(name: habitName, description: habitDesc, date: date, completedDates: [])
        
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
                        print("Error reading from db")
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
        
        if let docId = habit.docId {
            print("Toggling complete on habit with docID: \(docId)")
            let newValue = !habit.isCompleted
            var completedDates = habit.completedDates
            var currentStreak = habit.currentStreak
            
            if let habitDate = habit.date,
               Calendar.current.isDateInYesterday(habitDate),
               Calendar.current.isDate(latestDone, inSameDayAs: Date()) {
                // The habit was completed yesterday and today, so increase the current streak
                completedDates.append(latestDone)
                print(completedDates)
                currentStreak += 1
            } else {
                // The habit was not completed yesterday or today, so reset the current streak
                currentStreak = 0
            }
            
            print("Current streak: \(currentStreak)")
            
            habitsRef.document(docId).updateData([
                "isCompleted" : !habit.isCompleted,
                "latestDone" : latestDone,
                "currentStreak" : currentStreak,
                "completedDates" : FieldValue.arrayUnion([latestDone])
            ]) { error in
                if let error = error {
                    print("Error updating habit: \(error.localizedDescription)")
                } else {
                    print("Habit successfully updated! New value: \(newValue)")
                }
            }
        }
    }
}
