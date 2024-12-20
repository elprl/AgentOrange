//
//  Color+Utils.swift
//  TDCodeReview
//
//  Created by Paul Leo on 14/03/2022.
//  Copyright © 2022 tapdigital Ltd. All rights reserved.
//

import Foundation
import SwiftUI

extension Color: Codable {
    init(hexColor: String) {
        let rgba = hexColor.toRGBA()
        
        self.init(.sRGB,
                  red: Double(rgba.red),
                  green: Double(rgba.green),
                  blue: Double(rgba.blue),
                  opacity: Double(rgba.alpha))
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        
        self.init(hexColor: hex)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toHex)
    }
    
    var toHex: String? {
        return toHex()
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        var alphaV = Float(1.0)
        
        if components.count >= 4 {
            alphaV = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX",
                          lroundf(red * 255),
                          lroundf(green * 255),
                          lroundf(blue * 255),
                          lroundf(alphaV * 255))
        } else {
            return String(format: "%02lX%02lX%02lX",
                          lroundf(red * 255),
                          lroundf(green * 255),
                          lroundf(blue * 255))
        }
    }
    
    static var messageBlue: Color {
        Color(red: 0.13, green: 0.56, blue: 0.98, opacity: 1.00)
    }
    
    static var mustard: Color {
        Color(red: 0.97, green: 0.79, blue: 0.24, opacity: 1.00)
    }
    
    /**
     * Get contrast color in monochrome
     *
     * - Parameters:
     *   - color: A SwiftUI.Color input
     *   - maxContrast: Maximum contrast (128~255), default is 192
     * - Returns: A SwiftUI.Color representing the contrast color
     */
    func contrastColor(maxContrast: Int = 192) -> Color {
        let minContrast = 128
        
        // Extract RGB components from the SwiftUI.Color
        let components = self.cgColor?.components ?? [0, 0, 0]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        // Calculate luma
        let y = Int(round(0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b)))
        var oy = 255 - y // Opposite
        var dy = oy - y // Delta
        
        if abs(dy) > maxContrast {
            dy = (dy > 0 ? 1 : -1) * maxContrast
            oy = y + dy
        } else if abs(dy) < minContrast {
            dy = (dy > 0 ? 1 : -1) * minContrast
            oy = y + dy
        }
        
        // Convert the grayscale value back to a SwiftUI.Color
        let normalizedOy = Double(oy) / 255.0
        return Color(red: normalizedOy, green: normalizedOy, blue: normalizedOy)
    }
}

struct RGBColor {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
}

extension String {
    func toRGBA() -> RGBColor {
        var hexSanitized = self.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        if length == 6 {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        }
        
        return RGBColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// generate a color from a username for example
    var color: Color {
        let hash = self.hashValue
        let red = Double((hash & 0xFF0000) >> 16) / 255.0
        let green = Double((hash & 0x00FF00) >> 8) / 255.0
        let blue = Double(hash & 0x0000FF) / 255.0
        return Color(red: red, green: green, blue: blue)
    }
    
    func color(isDarkMode: Bool) -> Color {
        let hash = self.hashValue
        let red = Double((hash & 0xFF0000) >> 16) / 255.0
        let green = Double((hash & 0x00FF00) >> 8) / 255.0
        let blue = Double(hash & 0x0000FF) / 255.0
        
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        let contrastColor: Color
        if isDarkMode {
            // For dark mode, ensure the color is light enough
            contrastColor = brightness < 0.5 ?
            Color(red: min(red * 2, 1.0), green: min(green * 2, 1.0), blue: min(blue * 2, 1.0)) :
            Color(red: red, green: green, blue: blue)
        } else {
            // For light mode, ensure the color is dark enough
            contrastColor = brightness < 0.5 ?
            Color(red: red, green: green, blue: blue) :
            Color(red: red / 2, green: green / 2, blue: blue / 2)
        }
        
        return contrastColor
    }
}
