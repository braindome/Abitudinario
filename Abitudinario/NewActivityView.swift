//
//  NewActivityView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-29.
//

import Foundation
import SwiftUI

struct NewActivityView : View {
    
    @State var isSaved = false
    @State var activityName = ""
    @State var description = ""
    @EnvironmentObject var trackerVM : HabitTrackerViewModel
    @EnvironmentObject var statsVM : HabitStatsViewModel
    @EnvironmentObject var notificationManager : NotificationManager
    @Binding var selectedDate : Date
    @State var isPickerActive = false
    @State var dailyReminder = Date()
        
    var body: some View {
        NavigationView {
             VStack {
                 Text(selectedDate, formatter: DateFormatter.customFormat)
                 Spacer().frame(height: 80)
                 TextField("Activity Name", text: $activityName)
                     .customStyle()
                 TextEditor(text: $description)
                     .frame(width: 300, height: 200)
                     .border(.gray)
                     .padding()
                     .cornerRadius(10)
                     .overlay(
                         ZStack {
                             if description.isEmpty {
                                 Text("Description")
                                     .foregroundColor(Color(UIColor.placeholderText))
                                     .padding(.horizontal, 6)
                             }
                         }
                     )
                 Spacer(minLength: 40)
                 TimePickerView(isPickerActive: $isPickerActive, dailyReminder: $dailyReminder)
                 Button(action: {
                     print("Creating activity...")
                     let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: dailyReminder)
                     guard let hour = dateComponents.hour, let minute = dateComponents.minute else {return}
                     print("Daily reminder: \(hour):\(minute)")
                     notificationManager.createLocalNotification(title: activityName, hour: hour, minute: minute) { error in
                         if error == nil {
                             DispatchQueue.main.async {
                                 self.isPickerActive = false
                             }
                         }
                     }
                     trackerVM.habits.append(Habit(name: activityName, description: description, date: selectedDate, dailyReminder: dailyReminder))
                     trackerVM.addHabitToFirestore(habitName: activityName, habitDesc: description, date: selectedDate, dailyReminder: dailyReminder)
                     isSaved = true
                 }) {
                     Text("Save")
                 }
                 .padding(.vertical, 150)
                 .buttonStyle(.borderedProminent)
             }
             .onDisappear {
                 notificationManager.reloadLocalNotifications()
             }
         }
        .fullScreenCover(isPresented: $isSaved, content: {
            ContentView()
        })
    }
}

struct NewActivityView_Previews: PreviewProvider {
    @State static var selectedDate = Date()
    static var previews: some View {
        NewActivityView(selectedDate: $selectedDate)
    }
}

extension DateFormatter {
    static let customFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

struct TimePickerView: View {
    @Binding var isPickerActive: Bool
    @Binding var dailyReminder : Date
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                Spacer(minLength: 50)
                Toggle(isOn: $isPickerActive) {
                    Text("Daily reminder")
                }
                Spacer(minLength: 50)
            }
            
            if isPickerActive {
                DatePicker(
                    "",
                    selection: $dailyReminder,
                    displayedComponents: [.hourAndMinute]
                )
                .labelsHidden()
                .frame(height: 150)
                .environment(\.locale, Locale(identifier: "en_GB"))
                .onChange(of: dailyReminder) { newValue in
                    print(dateFormatter.string(from: newValue))
                }
            }
        }
    }
}
