//
//  VerticalBar.swift
//  VerticalBar
//
//  Created by Seth Hunter on 12/4/21.
//

import SwiftUI

struct VerticalBar: View {
    @Binding var sliderVal : Double
    var body: some View {
        VStack {
            GeometryReader { geo in
                VerticalSlider(
                    sliderVal: $sliderVal,
                    sliderHeight: geo.size.height
                )
            }
            Text("\(Int(self.sliderVal))")
                .font(.headline)
                .frame(width: 10.0)
                .padding(.bottom)
           
        }
    }
}
