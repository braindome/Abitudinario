//
//  HabitSummaryView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-05-02.
//

import SwiftUI

struct HabitSummaryView: View {
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
    @State var selectedInterval: DateInterval = .day


    var body: some View {
        NavigationView {
            VStack {
                Text("Summary")
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
                        ForEach(trackerVM.habits, id: \.self) { habit in
                            Text("\(habit.name) done")
                        }
                    }
                case .week:
                    Text("Wip")
                case .month:
                    List {
                        ForEach(trackerVM.habits, id: \.self) { habit in
                            let completedDates = trackerVM.filterByMonth(habit: habit, month: Calendar.current.component(.month, from: Date()))
                            Text("\(habit.name) done on \(completedDates.count) days this month")
                        }
                    }
                }


            }
            .onAppear() {
                trackerVM.listenToFirebase()
            }
        }
    }
}

struct HabitSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        HabitSummaryView()
    }
}
