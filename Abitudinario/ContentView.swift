//
//  ContentView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedDate = Date()
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
    let statsVM : HabitStatsViewModel
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!

    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(.trailing, 8)
                    }
                    DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date])
                        .padding()
                        .onChange(of: selectedDate, perform: { date in
                            print("Date in view: \(date)")

                        })
                        .datePickerStyle(.compact)
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")
                            .padding(.leading, 8)
                    }
                }
                List {
                    ForEach(trackerVM.habits/*.filter { Calendar.current.isDate($0.date ?? Date(), inSameDayAs: selectedDate) }*/) { habit in
                        HabitTrackerRowView(selectedDate: $selectedDate, habit: habit, vm: trackerVM, statsVM: statsVM)
                    }
                    .onDelete() { indexSet in
                        for index in indexSet {
                            trackerVM.delete(index: index)
                        }
                    }
                }

            }.onAppear() {
                print("\(selectedDate)")
                trackerVM.listenToFirebase()
                
            }
                .padding()
                .navigationTitle("Activity List")
                .navigationBarItems(trailing: NavigationLink(destination:
                                                                NewActivityView(selectedDate: $selectedDate)){
                                            Image(systemName: "plus")
                })

        }
    }
}


struct HabitTrackerRowView: View {
    @Binding var selectedDate : Date
    @State var isPresentingSheet = false
    var habit: Habit
    let vm : HabitTrackerViewModel
    let statsVM : HabitStatsViewModel
    
    private var isHabitCompleted: Bool {
        return vm.isHabitCompletedOnDate(habit: habit, date: selectedDate)
    }

    var body: some View {

        HStack {
            Button(action: {
                isPresentingSheet = true
            }) {
                Image(systemName: "info.square")
            }
            .sheet(isPresented: $isPresentingSheet) {
                HabitStatsView(habit: habit)
            }
            Text(habit.name).disabled(true)
            Spacer()
            Button(action: {
                vm.toggle(habit: habit, latestDone: selectedDate)
            }) {
                if isHabitCompleted {
                    Image(systemName: "checkmark.square")
                } else {
                    Image(systemName: "square")
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let trackerVM = HabitTrackerViewModel()
        let statsVM = HabitStatsViewModel()
        ContentView(statsVM: statsVM).environmentObject(trackerVM)
    }
}
