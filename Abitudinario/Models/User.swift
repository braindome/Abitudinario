//
//  User.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth

struct User : Codable, Identifiable {
    
    
    @DocumentID var docId : String?
    var id = UUID()
    var name : String?
    var email : String?
    var points : Int
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
        self.points = 0
    }
    
}
