//
//  ButtonStyles.swift
//  Abitudinario
//
//  Created by Antonio on 2023-05-04.
//

import Foundation
import SwiftUI

struct MaroonButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.maroon)
            .cornerRadius(10)
    }
}
