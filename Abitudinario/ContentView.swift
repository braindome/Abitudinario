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
    @EnvironmentObject var statsVM : HabitStatsViewModel
    @EnvironmentObject var notificationManager : NotificationManager
    @State private var isCreatePresented = false

    
    private static var notificationDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    private func timeDisplayText(from notification: UNNotificationRequest) -> String {
        guard let nextTriggerDate = (notification.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() else {return ""}
        return Self.notificationDateFormatter.string(from: nextTriggerDate)
    }
    
    @ViewBuilder
    var infoOverlayView: some View {
        switch notificationManager.authorizationStatus {
        case .authorized:
            if notificationManager.notifications.isEmpty {
                InfoOverlayView(
                    infoMessage: "No Notifications Yet",
                    buttonTitle: "Create",
                    systemImageName: "plus.circle",
                    action: {
                        isCreatePresented = true
                    }
                )
            }
        case .denied:
            InfoOverlayView(
                infoMessage: "Please Enable Notification Permission In Settings",
                buttonTitle: "Settings",
                systemImageName: "gear",
                action: {
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            )
        default:
            EmptyView()
        }
    }

    
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

            }
            .onAppear() {
                print("\(selectedDate)")
                trackerVM.listenToFirebase()
                notificationManager.reloadAuthorizationStatus()
            }
            .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                switch authorizationStatus {
                case .notDetermined:
                    notificationManager.requestAuthorization()
                case .authorized:
                    notificationManager.reloadLocalNotifications()
                default:
                break
                    
                }
                
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                notificationManager.reloadLocalNotifications()
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
    @State var showingStreakAlert = false
    @State var streakMessage = ""
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
                //showingStreakAlert = true
                if habit.currentStreak  > 1 {
                    showingStreakAlert = true
                    streakMessage = "You're on a \(habit.currentStreak)-day streak!"
                } else if habit.currentStreak == 0 {
                    showingStreakAlert = true
                    streakMessage = "Streak broken"
                }
            }) {
                if isHabitCompleted {
                    Image(systemName: "checkmark.square")
                } else {
                    Image(systemName: "square")
                }
            }
            .buttonStyle(PlainButtonStyle())
            .alert(isPresented: $showingStreakAlert) {
                Alert(title: Text("Streak!"), message: Text(streakMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let trackerVM = HabitTrackerViewModel()
        let statsVM = HabitStatsViewModel()
        ContentView().environmentObject(trackerVM).environmentObject(statsVM)
    }
}
