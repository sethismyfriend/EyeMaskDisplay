//
//  ContentView.swift
//  EyeLid Display
//
//  Created by Seth Hunter on 11/23/21.
//

import SwiftUI

struct ContentView: View {
    // 1
    @StateObject var viewModel = CalculatorViewModel()
    
    var body: some View {
        VStack {
            VStack {
            
            // 2
            Text(viewModel.output)
                .frame(width: 300,
                       height: 50,
                       alignment: .trailing)
                .font(.title)
                .background(Color.gray.opacity(0.2))
                .padding(.bottom)
 
            // 3
            KeypadView(viewModel: viewModel)

            // 4
            ConnectButtonView(viewModel: viewModel)
            
            }
        }
    }
}


