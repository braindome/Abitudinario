//
//  LoginView.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation
import FirebaseAuth
import SwiftUI

struct LoginView : View {
    
    @State var signedIn = false
    @State var isPresentingSheet = false
    @ObservedObject var loginVM : LoginVM
    @EnvironmentObject var trackerVM : HabitTrackerViewModel

    
    var body: some View {
        
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 200, height: 200)
                    Spacer()
                    TextField("Email", text: $loginVM.email)
                        .padding(.horizontal, 50)
                    Spacer().frame(height: 40)
                    TextField("Password", text: $loginVM.password)
                        .padding(.horizontal, 50)
                    Spacer()
                    Button(action: {
                        print("log in")
                        loginVM.signInWithEmailAndPassword()
                        loginVM.onSignInSuccess = {
                            signedIn = true
                        }
                    }) {
                        Text("Log in")
                    }
                    .buttonStyle(MaroonButtonStyle())
                    .padding(10)
                    Button(action: {
                        print("new user")
                        if signedIn == false {
                            isPresentingSheet = true
                        } else {
                            print("User is already signed in")
                        }
                    }) {
                        Text("Create Account")
                    }
                    .buttonStyle(MaroonButtonStyle())
                    .padding(10)
                    .sheet(isPresented: $isPresentingSheet) {
                        CreateUserView(loginVM: loginVM)
                    }
                }
            }
            .padding()
            .background(Color.lightCeleste.opacity(0.2))

        }
        .background(Color.softOrange)
        .fullScreenCover(isPresented: $signedIn, content: {
            ContentView()
        })
    }
}

struct LoginView_Previews : PreviewProvider {
    static var previews: some View {
        let loginVM = LoginVM(email: "", password: "", name: "")
        return LoginView(loginVM: loginVM)
    }
    
    
}

struct CreateUserView: View {
    
    @ObservedObject var loginVM : LoginVM
    @State var signedIn = false
    
    var body: some View {
       NavigationView {
            VStack {
                Spacer().frame(height: 40)
                TextField("Name", text: $loginVM.name)
                    .customStyle()
                TextField("Email", text: $loginVM.email)
                    .customStyle()
                TextField("Password", text: $loginVM.password)
                    .customStyle()
                Spacer()
                Button(action: {
                    print("create user")
                    loginVM.createUserWithEmailAndPassword()
                    loginVM.onUserCreationSuccess = {
                        signedIn = true // Set signedIn to true upon successful user creation
                    }
                }) {
                    Text("Save")
                }
                .padding(.vertical, 150)
                .buttonStyle(.borderedProminent)
            }
        }
       .fullScreenCover(isPresented: $signedIn, content: {
           ContentView()
       })
       
    }
    
}
