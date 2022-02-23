//
//  ExampleSeth.swift
//  ExampleSeth
//
//  Created by Seth Hunter on 12/20/21.
//
//
//  ForSeth.swift
//  Houdini
//
//  Created by Tim Cornelissen on 12/16/21.
//

import SwiftUI

struct ForSeth: View {
    
    @State var LEDMatrix: [Double] = [0, 1, 2, 3, 4]
    
    
    var body: some View {
        Text("Tap here to change the value of LEDMatrix")
            .onChange(of: LEDMatrix, perform: { newValue in
                /*
                 
                 .onChange responds to any chaneg in LEDMatrix
                 
                Assuming your btmanager has an explicit method to send a value to the hardware:
                btManager.send(newValue)
                
                Or if btManager is just continuously sending one of its own properties:
                btManager.LEDMatrix = newValue
                 
                in the latter case you do not need @published inside btManager at all
                 
                You may still need to pass BtManager down to the view that changes LEDMatrix, but that doesn't need any fancy bindings I think?
                
                */
                
                // in this example we'd just print the new value in stead of sending it
                print("the new value of LEDMatrix = \(LEDMatrix)")
            })
            .onTapGesture {
                LEDMatrix[0] = LEDMatrix[0] + 1 // when we tap on the text, change an element in LED matrix to trigger the action in .onChange()
            }
        
        // the only caveat here is that LEDMAtrix needs to conform to "equatable" I believe, e.g. you need to be able to compare two instances (like doing LEDMatrix1 == LEDMatrix2)
        
        
    }
}

struct ForSeth_Previews: PreviewProvider {
    static var previews: some View {
        ForSeth()
    }
}
