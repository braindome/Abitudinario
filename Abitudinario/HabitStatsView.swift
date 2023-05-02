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
    @EnvironmentObject var statsVM : HabitStatsViewModel
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
    @State var isPresented = false
    
    var body: some View {
        let statsVM = HabitStatsViewModel()
        NavigationView {
            VStack {
                Button(action: {
                    if let docId = habit.docId {
                        statsVM.getStatsFromFirestore(docId: docId)
                    }
                }) {
                    Text("Get")
                }
                List {
                    ForEach(habit.completedDates, id: \.self) { date in
                        Text("\(date, formatter: DateFormatter.customFormat)")
                    }
                }

                Text("\(habit.name)")

            }
            .onAppear() {
                trackerVM.listenToFirebase()
            }
        }
        .fullScreenCover(isPresented: $isPresented, content: {
            ContentView()
        })
    }
}

extension String: Identifiable {
    public var id: String {
        return self
    }
}

struct HabitStatsView_Previews: PreviewProvider {
    static var previews: some View {
        HabitStatsView(habit: Habit(name: "Preview habit", description: "Just a preview"))
    }
}
