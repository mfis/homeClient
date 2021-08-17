//
//  PinView.swift
//  homeClient WatchKit Extension
//
//  Created by Matthias Fischer on 05.10.20.
//

import SwiftUI

struct PinView: View {
    
    var length:  Int
    @Binding var pin:  String
    @Binding var showModal: Bool
    
    var body: some View {
        GeometryReader { proxy in
            VStack{
                HStack(spacing: 4) {
                    ForEach(0 ..< length) { index in
                        Circle()
                            .fill(Color.primary.opacity(index < pin.count
                                                            ? 0.9
                                                            : 0.3))
                            .frame(width: 10,
                                   height: 10,
                                   alignment: .center)
                    }
                }.padding(.bottom, 5)
                HStack {
                    Button("1"){press("1")}.buttonStyle(PinButton())
                    Button("2"){press("2")}.buttonStyle(PinButton())
                    Button("3"){press("3")}.buttonStyle(PinButton())
                }
                HStack {
                    Button("4"){press("4")}.buttonStyle(PinButton())
                    Button("5"){press("5")}.buttonStyle(PinButton())
                    Button("6"){press("6")}.buttonStyle(PinButton())
                }
                HStack {
                    Button("7"){press("7")}.buttonStyle(PinButton())
                    Button("8"){press("8")}.buttonStyle(PinButton())
                    Button("9"){press("9")}.buttonStyle(PinButton())
                }
                HStack {
                    Button("X"){pin = ""; showModal = false}.buttonStyle(PinButton())
                    Button("0"){press("0")}.buttonStyle(PinButton())
                    Button("←"){pin = ""}.buttonStyle(PinButton())
                }
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    func press(_ number : String){
        pin = pin + number
        if(pin.count==length){
            showModal = false
        }
    }
}

struct PinButton: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 10, maxHeight: 15)
            .padding()
            .foregroundColor(.white)
            .background(Color.init(hexOrName: ".black"))
            .cornerRadius(4)
            .scaleEffect(configuration.isPressed ? 2.0 : 1.0)
            .font(.headline)
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(length: 6, pin: .constant(""), showModal: .constant(true)).toolbar(content: {
            
        })
    }
}
