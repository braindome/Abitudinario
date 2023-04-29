//
//  LoginVM.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class LoginVM : ObservableObject {
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    
    @Published var email : String
    @Published var password : String
    @Published var name : String
    
    var onUserCreationSuccess: (() -> Void)? // Callback closure for successful user creation
    var onSignInSuccess: (() -> Void)?
    
    init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name
    }
    
    func createUserWithEmailAndPassword() {
        auth.createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user, error == nil else {
              print("Error creating user: \(error!.localizedDescription)")
              return
            }
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else if authResult != nil {
                // Creates both new auth user and firestore document with auth uid as docID
                let newUser = User(name: self.name, email: self.email)
                let usersRef = self.db.collection("Users").document(user.uid)
                
                
                if let name = newUser.name, let email = newUser.email {
                    usersRef.setData([
                        "name": name,
                        "email": email]) { error in
                            if let error = error {
                                print("Error adding document: \(error.localizedDescription)")
                            } else {
                                print("Document added with ID: \(usersRef.documentID)")
                                self.onUserCreationSuccess?()
                            }
                        }
                }
            }
        }
    }
    
    func signInWithEmailAndPassword() {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                print("Successful signin")
                self.onSignInSuccess?()
            }
        }
    }
    
    func signOut() {
        do {
          try auth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
    
}

