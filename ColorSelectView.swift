//
//  ColorSelectView.swift
//  MyCalendar
//
//  Created by ヒロタコウダイ on 2023/11/29.
//

import SwiftUI

struct ColorSelectView: View {
    @Binding var selectedColor: String
    let colors: Array<String>
    let diameter: Double
    
    var body: some View {
        HStack {
            ForEach(colors, id: \.self) {color in
                ZStack {
                    let rgb = rgbDecode(code: color)
                    Circle()
                        .foregroundColor(Color(red: rgb[0], green: rgb[1], blue: rgb[2]))
                        .frame(width: diameter, height: diameter)
                        .padding(2)
                    Circle()
                        .stroke(selectedColor == color ? Color.blue : Color.gray, lineWidth: 2)
                        .frame(width: diameter+2, height: diameter+2)
                }.onTapGesture {
                    selectedColor = color
                }
            }
        }
    }
}
