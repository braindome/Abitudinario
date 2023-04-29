//
//  HabitStatsView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import SwiftUI

struct HabitStatsView: View {
    @State var habit : Habit
    //var statsVM : HabitStatsViewModel
    
    var body: some View {
        let statsVM = HabitStatsViewModel()
        VStack {
            Button(action: {
                if let docId = habit.docId {
                    statsVM.getStatsFromFirestore(docId: docId)
                }
            }) {
                Text("Get")
            }
            List {
                ForEach(statsVM.formattedDates) { date in
                    Text(date)
                }
            }

            Text("\(habit.name)")

        }
        .onAppear() {
            if let docId = habit.docId {
                print("Reading stats for \(habit.name)")
                statsVM.getStatsFromFirestore(docId: docId)
            }
        }
        
    }
}

extension String: Identifiable {
    public var id: String {
        return self
    }
}

struct HabitStatsView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = HabitStatsViewModel()
        HabitStatsView(habit: Habit(name: "Preview habit", description: "Just a preview"))
    }
}
