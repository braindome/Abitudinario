//
//  TextFieldStyleAuth.swift
//  Abitudinario
//
//  Created by Antonio on 2023-04-28.
//

import Foundation

import SwiftUI

struct TextFieldStyleAuth: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 50)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 300)
            .multilineTextAlignment(.center)
            .padding()
    }
}

extension TextField {
    func customStyle() -> some View {
        self.modifier(TextFieldStyleAuth())
    }
}
