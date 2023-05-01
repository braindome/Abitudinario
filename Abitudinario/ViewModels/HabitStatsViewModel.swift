//
//  HabitStatsViewModel.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import SwiftUI
import Firebase

class HabitStatsViewModel : ObservableObject {
        
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @Published var retrievedDates = [Date]()
    @Published var formattedDates = [String]()
    
    func getStatsFromFirestore(docId: String) {
        guard let user = auth.currentUser else {return}
        let habitsRef = db.collection("Users").document(user.uid).collection("Habits").document(docId)
        
        print("Getting dates....")

        /*habitsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let completedTimestamps = document.get("completedDates") as! [Timestamp]
                let completedDates = completedTimestamps.map { $0.dateValue() }
                print(completedDates)
            } else {
                print("Could not retrieve dates")
            }
        }*/
        
        habitsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let completedTimestamps = document.get("completedDates") as! [Timestamp]
                let completedDates = completedTimestamps.map { $0.dateValue() }
                let sortedDates = completedDates.sorted(by: { $0 > $1 })
                let formattedDates = self.formatDates(sortedDates)
                DispatchQueue.main.async {
                    self.formattedDates.append(contentsOf: formattedDates)
                    self.retrievedDates.append(contentsOf: sortedDates)
                }
                print(formattedDates)
            } else {
                print("Could not retrieve dates")
            }
        }
    }
    
    func formatDates(_ dates: [Date]) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        return dates.map { formatter.string(from: $0) }
    }
    
}

