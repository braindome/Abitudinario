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
    @Binding var selectedDate : Date
        
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
                 Spacer()
                 Button(action: {
                     // TODO: save to firestore
                     print("Creating activity...")
                     trackerVM.habits.append(Habit(name: activityName, description: description, date: selectedDate))
                     trackerVM.addHabitToFirestore(habitName: activityName, habitDesc: description, date: selectedDate)
                     isSaved = true
                 }) {
                     Text("Save")
                 }
                 .padding(.vertical, 150)
                 .buttonStyle(.borderedProminent)
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
