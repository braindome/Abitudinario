//
//  AbitudinarioApp.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import SwiftUI
import SwiftUI

import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct AbitudinarioApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var loginVM = LoginVM(email: "", password: "", name: "")
    @StateObject var trackerVM: HabitTrackerViewModel // New version
    @StateObject var statsVM: HabitStatsViewModel

    init() {
        _trackerVM = StateObject(wrappedValue: HabitTrackerViewModel())
        _statsVM = StateObject(wrappedValue: HabitStatsViewModel())
    }

    var body: some Scene {
        WindowGroup {
            LoginView(loginVM: loginVM).environmentObject(trackerVM).environmentObject(statsVM)

        }
    }
}
