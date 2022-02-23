//
//  RoundedButton.swift
//  RoundedButton
//
//  Created by Seth Hunter on 11/29/21.
//

import SwiftUI

struct RoundedButton: ButtonStyle {
    let lightOutline: Color = Color(red:0.75,green:0.75, blue:0.75)
    let darkOutline: Color = Color(red:0.25,green:0.25, blue:0.25)
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 18, alignment: .center)
            .padding(10)
            .background(colorScheme == .dark ? darkOutline : lightOutline)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .heavy))
            .cornerRadius(10.0)
    }
}

