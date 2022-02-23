//
//  Led.swift
//  Led
//
//  Created by Seth Hunter on 11/25/21.
//

import SwiftUI


struct Led: View {
    var isTouched: Bool = false
    var myIndex: Int = 0
    var curColor: Color = .red
    var offColor: Color = .black
    var size: CGFloat = 20.0
    let lightOutline: Color = Color(red:0.75,green:0.75, blue:0.75)
    let darkOutline: Color = Color(red:0.25,green:0.25, blue:0.25)
    var ledMode: ledModes = ledModes.toggle
    
    @Environment(\.colorScheme) var colorScheme
    
    init(sizeIs:CGFloat,touched:Bool,dColor:Color,ledM:ledModes) {
        size = sizeIs
        isTouched = touched
        curColor = dColor
        ledMode = ledM
    }
    
    //stroke and background is the only way to do this... not fill ans stroke. weird. 
    var body: some View {
        
        Rectangle()
            .strokeBorder(colorScheme == .dark ? darkOutline : lightOutline, lineWidth: 4)
            .background(updateLED())
            .frame(width: size, height: size, alignment: .center)
    }
    
    func updateLED() -> Color {
        if(ledMode == .toggle) {
            return curColor
        } else if (ledMode == .fadeSlow) {
            //use the color mixer or fader here? 
        }
        
        return curColor
    }
    
    // This is a very basic implementation of a color interpolation
    // between two values.
    func colorMixer(c1: UIColor, c2: UIColor, pct: CGFloat) -> Color {
        guard let cc1 = c1.cgColor.components else { return Color(c1) }
        guard let cc2 = c2.cgColor.components else { return Color(c1) }

        let r = (cc1[0] + (cc2[0] - cc1[0]) * pct)
        let g = (cc1[1] + (cc2[1] - cc1[1]) * pct)
        let b = (cc1[2] + (cc2[2] - cc1[2]) * pct)

        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
}

/*
struct Led_Previews: PreviewProvider {
    static var previews: some View {
        Led(sizeIs:20.0,touched:false,dColor: .purple)
    }
}
 */
