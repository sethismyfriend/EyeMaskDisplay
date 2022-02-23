//
//  LedMatrix.swift
//  LedMatrix
//
//  Created by Seth Hunter on 11/25/21.
//

import SwiftUI



struct LedMatrix: View {
    //variables that you can override but have defaults
    var col: Int = 8
    var row: Int = 8
    var pad: CGFloat = 0
    var diam: CGFloat = 35.0
   
    
    //order of instatiation matters. Bound variables are linked to the parent class
    @Binding var allLEDColors: [Color]
    @Binding var colorPicked: Color
    @GestureState private var location: CGPoint = .zero   //holds position of an updating drag gesture
    @State private var indexTouched: Int? = nil
    @Binding var ledMode: ledModes

    //gesture is attached to each LED and reports global location to a GestureState
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .updating($location) {
                (value, state, transaction) in
                state = value.location
            }
            .onEnded {_ in
                self.indexTouched = nil
            }
    }
    
    //instatiates a matrix of LEDs with a color that matches drag color in LED arrays at root
    var body: some View {
        HStack {
            VStack(spacing: pad) {
                ForEach(0..<self.row) {i in
                    HStack(spacing: pad) {
                        ForEach(0..<self.col) {j in
                            Led(sizeIs:diam,
                                touched: self.indexTouched == (i*self.col)+j,
                                dColor: allLEDColors[(i*self.col)+j],
                                ledM: ledMode)
                                .gesture(drag)
                                .background(self.dragTracker(index: (i*self.col)+j))
                        }
                    }
                }
            }
        }
        
    }
    
    //function returns a view and dispatches to the bound variable AllLEDColors based on color picked
    func dragTracker(index: Int) -> some View {
        return GeometryReader { (geometry) -> AnyView in
            if geometry.frame(in: .global).contains(self.location) {
                //print("index = \(index)")
                //print("indexTouched = \(self.indexTouched ?? -1)")
                //print(allLEDColors)
                DispatchQueue.main.async {
                    self.indexTouched = index
                    self.allLEDColors[index] = colorPicked
                }
            }
            return AnyView(Rectangle().fill(Color.clear))
        }
    }
    

    
}

/*
 struct LedMatrix_Previews: PreviewProvider {
 static var previews: some View {
 LedMatrix()
 }
 }
 */
