//
//  ToggleButton.swift
//  AgentOrange
//
//  Created by Paul Leo on 23/11/2024.
//  Copyright © 2024 tapdigital Ltd. All rights reserved.
//

import SwiftUI

struct ToggleButton: View {
    var title: String
    @Binding var isOn: Bool
    var onColor: Color = .black
    var offColor: Color = .gray.opacity(0.5)
    var onTextColor: Color = .white
    var offTextColor: Color = .white
    let action: () -> Void

    var body: some View {
        Button {
            self.isOn.toggle()
            self.action()
        } label: {
            Text(self.title)
                .lineLimit(1)
                .font(.system(size: 14))
                .foregroundColor(isOn ? onTextColor : offTextColor)
                .padding(.horizontal)
                .padding(.vertical, 2)
        }
        .buttonStyle(ToggleButtonStyle(bgColor: isOn ? onColor : offColor, fgColor: isOn ? onTextColor : offTextColor))
    }
}

struct ToggleButtonStyle: ButtonStyle {
    let bgColor: Color
    let fgColor: Color
    let borderColor: Color

    init(bgColor: Color = .white, fgColor: Color = .black, borderColor: Color = .clear) {
        self.bgColor = bgColor
        self.fgColor = fgColor
        self.borderColor = borderColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(fgColor)
            .background(
                ZStack {
                    bgColor
                    Capsule()
                        .stroke(borderColor, lineWidth: 3)
                }
            )
            .contentShape(Capsule())
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#if DEBUG

#Preview {
    @Previewable @State var isOn: Bool = false
    VStack {
        ToggleButton(title: "Toggle", isOn: $isOn) {
            
        }
        .padding()
    }
}

#endif
