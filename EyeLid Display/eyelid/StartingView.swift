//
//  ContentView.swift
//  SwiftUILocal
//
//  Created by Seth Hunter on 11/24/21.
/*
 
 Order of Experimentation:
 -Continuous mode
    -can you only send the updated changes to firmware?
    -how much more repsonsive does this make the update with less data?
    -add a clear function in firmware for efficiency?

 
 Ideas:
 -Fix brightness slider to be relative brightness
 -In Continuous mode add a button for parallel view
 -In Continuous mode gradually fade every pixel to black - like yellowtail.
 -Move UI control to a pane that animates up
 -Add seperate UI pane for animated sequences
 -Add animation sequence pane with target colors on a timeline?
 -Allow input of camera to control brightness of pixels
 -Add frames to compositions and control output
 -Add audio and some how sychronize LED output to the audio in the app
 -Experiment with less LEDs for eyelid concept
 -Experiment with diffusers for open eye mode - limit brightness in this mode
 
 Feedback from Eric:
 -can you feed sound in from other apps - sound will be a big part of it
 -transition between colors and frames for animations
 -adjusting the headroom of the brightness
 -focus on the eyes closed experiences and the mix of brain/fill in
 -pyschedelic technologies will be a big component of the experience (Jay and conference)
 -Blues and greens more soothing - reds more intense
 
 -Focus on developing a UI for improvision first 
 
 Feedback from Family:
 -Would be cool to have lights timed to peaks in the music
 -Use this tutorial as a starting point: https://audiokitpro.com/audiovisualizertutorial/
 -Ben thinks I should make cups so that it does not touch your eyelid
 -He liked the feild of color that is created with the diffuser
 -Try the other diffuser an see if it goes flatter on the LEDs and how much light goes through
 -Mimi said she would use it to relax or to help her in the middle of the night not to have anxious thoughts
 
 
 
 
 */
//

import SwiftUI

enum ledModes:UInt8 {
    case toggle, fadeFast, fadeSlow, colorAnimation
}

struct StartingView: View {
    //declare states before body
    @State private var clearMatrix: Bool = false
    @State var colorPicked: Color = .green
    @State var allLEDColors1 = Array(repeating: Color.black, count: 64)
    @State var allLEDColors2 = Array(repeating: Color.black, count: 64)
    @State var ledMode: ledModes = ledModes.toggle
    let lightOutline: Color = Color(red:0.75,green:0.75, blue:0.75)
    let darkOutline: Color = Color(red:0.25,green:0.25, blue:0.25)
    
    @Environment(\.colorScheme) var colorScheme  //related to the UI: dark or light
    @StateObject var btManager = BluetoothManager()  //manages all the data - should probobly be an Environment variable
    @State var brightness: Double = 3.0
    
    var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack {
                LedMatrix(diam: 32, allLEDColors: $allLEDColors2.onChange(leds1Changed), colorPicked: $colorPicked, ledMode: $ledMode)
                Button(action: {
                    self.allLEDColors2 = Array(repeating: Color.black , count: 64)
                    btManager.allLEDColors2 = Array(repeating: Color.black , count: 64)
                },
                       label: {Text("clear")}
                ).buttonStyle(RoundedButton())
            }
            
            Spacer()
            Spacer()
            
            VStack {
                LedMatrix(diam: 32, allLEDColors: $allLEDColors1.onChange(leds2Changed), colorPicked: $colorPicked, ledMode: $ledMode)
                Button(action: {
                    self.allLEDColors1 = Array(repeating: Color.black , count: 64)
                    btManager.allLEDColors1 = Array(repeating: Color.black , count: 64)
                },
                       label: {Text("clear")}
                ).buttonStyle(RoundedButton())
            }
            
            Spacer()
            
            //vertical slider
            /*
            Slider(value: $brightness, in: 0...31)
                .rotationEffect(.degrees(-90.0), anchor: .topLeading)
                .frame(width: 100)
                .offset(y: 0)
             */
            Spacer()
            
            VStack {
                //Spacer()
                VerticalBar(sliderVal: $brightness)
                    .frame(width: 30, height: 250, alignment: .center)
                //Spacer()
            }
            
            
    
            
            VStack {
                Spacer()
                
                
                ColorPicker("", selection: $colorPicked)
                    .scaleEffect(CGSize(width: 2.5, height: 2.5))
                    .labelsHidden()
                
                Spacer()
                
                if btManager.connected {
                    Button(action: {
                        btManager.disconnectMask()
                    }, label: {
                        Text("Disconnect")
                            .padding()
                    }).buttonStyle(RoundedButton())
                } else {
                    Button(action: {
                        btManager.connectToMask()
                    }, label: {
                        Text("Connect")
                            .padding()
                    }).buttonStyle(RoundedButton())
                }
                
                /*
                Spacer()
                Text(btManager.output)
                    .frame(height: 35, alignment: .center)
                    .font(.body)
                    .background(Color.gray.opacity(0.2))
                    .padding(10)
                    .cornerRadius(10)
                
                */
                
                //Spacer()
                
                if btManager.continuousUpdate {
                    Button(action: {
                        btManager.stopContinuous()
                    }, label: {
                        Text("Discrete")
                            .padding()
                    }).buttonStyle(RoundedButton())
                } else {
                    Button(action: {
                        btManager.startContinuous()
                    }, label: {
                        Text("Continuous")
                            .padding()
                    }).buttonStyle(RoundedButton())
                }
                
                
                Button("Send to Mask") {
                    //add send actions here
                    btManager.formatData(brightness: UInt8($brightness.wrappedValue))
                    btManager.sendData()
                    
                }   .padding(10)
                    .foregroundColor(.white)
                    .background(.gray)
                    .font(.system(size: 16, weight: .heavy))
                    .cornerRadius(10)
                
                
                Spacer()
            }
            
            //Spacer()
        }
        
    }
    
    //function is inside of start view definition
    func leds1Changed(to value: [Color]) {
        btManager.setLeftEye(leftEye: allLEDColors2)
        }
    
    //function is inside of start view definition
    func leds2Changed(to value: [Color]) {
        btManager.setRightEye(rightEye: allLEDColors1)
        }
    
}

//extension to allow an onChange handler function to LEDArray
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}
