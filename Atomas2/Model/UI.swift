import Foundation
import UIKit
import SwiftUI
import CoreGraphics

// Extend UIColor to accept hexcodes
extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
}

// Use the extended UIColor to define custom colors
extension Color {
  static let customGrey = Color(UIColor(rgb: 0xE6E6E6))
  static let customWhite = Color(UIColor(rgb: 0xFAFAFA))
}


// Element circle
struct Tile: View {
  var element: Int
  var elements: [Int: Element]
  
  var body: some View {
    ZStack {
      Circle()
        .fill(Color(UIColor(rgb: elements[element]!.color)))
        .frame(width: 50, height: 50)
      
      VStack {
        Text(elements[element]!.symbol)
          .foregroundColor(Color.white)
          .bold()
          .font(.system(size: 18))
          .disabled(true)
          .padding(0)
        if(element > 0) {
          Text(String(element))
            .foregroundColor(Color.white)
            .font(.system(size: 10))
            .disabled(true)
            .padding(0)
        }
      }
    }
  }
}


struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 2) // Border color and width
                    .opacity(configuration.isPressed ? 0.6 : 1.0) // Opacity change on press
            )
            .foregroundColor(Color.accentColor) // Text color
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Scale effect on press
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle {
        GhostButtonStyle()
    }
}

// TODO: tile pulse

