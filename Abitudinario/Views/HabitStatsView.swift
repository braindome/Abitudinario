//
//  HabitStatsView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import SwiftUI

enum DateInterval {
    case day, week, month
}

struct HabitStatsView: View {
    @State var habit : Habit
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
    @State var isPresented = false
    @State var selectedInterval: DateInterval = .day
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Stats for \(habit.name)")
                HStack {
                    Text("View by:")
                    Picker("Date Interval", selection: $selectedInterval) {
                        Text("Daily").tag(DateInterval.day)
                        Text("Weekly").tag(DateInterval.week)
                        Text("Monthly").tag(DateInterval.month)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                
                switch selectedInterval {
                case .day:
                    List {
                        ForEach(habit.completedDates, id: \.self) { date in
                            Text("\(date, formatter: DateFormatter.customFormat)")
                        }
                    }
                case .week:
                    Text("Wip")
                case .month:
                    Text("Wip")
                }


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
