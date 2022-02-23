//
//  VerticalSlider.swift
//  VerticalSlider
//
//  Created by Seth Hunter on 12/4/21.
//

import SwiftUI

struct VerticalSlider: View {
    @Binding var sliderVal : Double
    var sliderHeight:CGFloat 

    var body: some View {
        Slider(
            value: self.$sliderVal,
            in: 0...31,
            step: 1.0
        ).rotationEffect(.degrees(-90.0), anchor: .topLeading)
        .frame(width: sliderHeight)
        .offset(y: sliderHeight)
    }
}
