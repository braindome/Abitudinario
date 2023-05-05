//
//  ContentView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import SwiftUI
import SwiftUIX

struct ContentView: View {
    
    @State var selectedDate = Date()
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
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
        ZStack {
            NavigationView {
                ZStack {
                    VStack {
                        ZStack {
                            HStack {
                                Button(action: {
                                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                                    print("Date in view: \(selectedDate)")
                                }) {
                                    Image(systemName: "chevron.left")
                                        .padding(.trailing, 8)
                                        .foregroundColor(.black)
                                }
                                DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date])
                                    .padding()
                                    .onChange(of: selectedDate, perform: { date in
                                        print("Date in view: \(date)")

                                    })
                                    .datePickerStyle(.compact)
                                Button(action: {
                                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                                    print("Date in view: \(selectedDate)")
                                }) {
                                    Image(systemName: "chevron.right")
                                        .padding(.leading, 8)
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        ZStack {
                            List {
                                ForEach(trackerVM.habits) { habit in
                                    HabitTrackerRowView(selectedDate: $selectedDate, habit: habit, vm: trackerVM)
                                }
                                .onDelete() { indexSet in
                                    for index in indexSet {
                                        trackerVM.delete(index: index)
                                    }
                                }
                            }
                        }
                    }
                    .onAppear() {
                        selectedDate = selectedDate.withDefaultTimeZone()
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
                    .navigationBarItems(
                        leading: NavigationLink(destination: HabitSummaryView()) {
                        Image(systemName: "info.square")
                                .foregroundColor(.black)
                    },
                        trailing: NavigationLink(destination: NewActivityView(selectedDate: $selectedDate)) {
                        Image(systemName: "plus")
                                .foregroundColor(.black)
                    })
                }
            }
        }
    }
}


struct HabitTrackerRowView: View {
    @Binding var selectedDate : Date
    @State var isPresentingSheet = false
    @State var showingStreakAlert = false
    @State var streakMessage = ""
    @State var streak: Int?
    var habit: Habit
    let vm : HabitTrackerViewModel
    
    private var isHabitCompleted: Bool {
        return vm.isHabitCompletedOnDate(habit: habit, date: selectedDate)
    }

    var body: some View {

        ZStack {

            HStack {
                Button(action: {
                    isPresentingSheet = true
                }) {
                    Text("")
                }
                .sheet(isPresented: $isPresentingSheet) {
                    HabitStatsView(habit: habit)
                }
                Text(habit.name).disabled(true)
                Spacer()
                Button(action: {
                    vm.getStreak(habit: habit) { streak in
                        // Asynchronously get streak from db. With the closure, it is possible
                        // to capture the result of the method and update the UI. Closure = completion handler
                        if let streak = streak {
                            self.streak = streak
                            if habit.currentStreak >= 1 {
                                showingStreakAlert = true
                                streakMessage = "You're on a \(streak)-day streak!"
                            }
                        } else {
                            print("error getting streak")
                        }
                    }
                    vm.toggle(habit: habit, latestDone: selectedDate)
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
}


// Bugfix: UI DatePicker date showing a day after the logged date
extension Date {
    func withDefaultTimeZone() -> Date {
        let timeZoneOffset = TimeZone.current.secondsFromGMT()
        return Date(timeInterval: TimeInterval(timeZoneOffset), since: self)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let trackerVM = HabitTrackerViewModel()
        let notifm = NotificationManager()
        ContentView().environmentObject(trackerVM).environmentObject(notifm)
    }
}
