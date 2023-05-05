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
    @State var selectedWeek: Int = 1
    @State var viewOption = Date()
    
    let weekNumber: (Date) -> Int = { date in
        return Calendar.current.component(.weekOfYear, from: date)
    }


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
                
                if selectedInterval == .month{
                    MonthYearPicker(viewOption: $viewOption)
                } else if selectedInterval == .week {
                    //WeekPicker(viewOption: $viewOption)
                    WeekPicker(selectedWeek: $selectedWeek)
                } else if selectedInterval == .day {
                    Form {
                        DatePicker(
                            selection: $viewOption,
                            displayedComponents: [.date],
                            label: { Text("Choose a day") }
                        )
                    }
                }
                
                switch selectedInterval {
                case .day:
                        List {
                            ForEach(trackerVM.habits, id: \.self) { habit in
                                let completedDates = trackerVM.filterByDay(habit: habit, date: viewOption)
                                if completedDates.count > 0 {
                                    Text("\(habit.name) done this day")
                                }
                            }
                        }
                case .week:
                   Group {
                        List {
                            ForEach(trackerVM.habits, id: \.self) { habit in
                                let completedDates = trackerVM.filterByWeekNumber(habit: habit, week: selectedWeek)
                                Text("\(habit.name) completed \(completedDates.count) days this week")
                            }
                        }
                       Spacer()
                    }
                case .month:
                    List {
                        ForEach(trackerVM.habits, id: \.self) { habit in
                            let completedDates = trackerVM.filterByMonth(habit: habit, month: Calendar.current.component(.month, from: viewOption))
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

struct WeekPicker: View {
    
    @Binding var selectedWeek : Int
    
    var body: some View {

        VStack {
            Text("Selected Week \(selectedWeek)")
            Picker("Week", selection: $selectedWeek) {
                ForEach(1..<53) { week in
                    Text("Week \(week - 1)")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }

    }
}

struct MonthYearPicker: View {
    
    let dateFormatter = DateFormatter()
    let years = Array(2021...2030)
    
    @Binding var viewOption: Date
    
    @State private var selectedMonth = 0
    @State private var selectedYear = 0
    
    var body: some View {

        VStack {
            ZStack { 
                HStack {
                    Picker(selection: $selectedMonth, label: Text("Month")) {
                        ForEach(0..<dateFormatter.monthSymbols.count) { index in
                            Text(dateFormatter.monthSymbols[index]).tag(index)
                        }
                    }
                    
                    Picker(selection: $selectedYear, label: Text("Year")) {
                        ForEach(0..<years.count) { index in
                            Text(String(years[index])).tag(index)
                        }
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .onAppear {
            dateFormatter.dateFormat = "MMMM"
            let components = Calendar.current.dateComponents([.month, .year], from: viewOption) // Using DateComponents to extract month and year from date
            guard let month = components.month else {return}
            guard let year = components.year else {return}
            selectedMonth = month - 1                       // Setting them to initial values of month and year
            selectedYear = year - years[0]
        }
        .onChange(of: selectedMonth) { month in
            updateSelectedDate()
        }
        .onChange(of: selectedYear) { year in
            updateSelectedDate()
        }

    }
    
    func updateSelectedDate() {
        let newDateComponents = DateComponents(year: years[selectedYear], month: selectedMonth + 1)
        guard let newDate = Calendar.current.date(from: newDateComponents) else {return}
        viewOption = newDate
    }
}

struct HabitSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let trackerVM = HabitTrackerViewModel()
        let notifm = NotificationManager()
        HabitSummaryView().environmentObject(trackerVM).environmentObject(notifm)
    }
}
