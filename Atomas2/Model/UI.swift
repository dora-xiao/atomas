import Foundation
import UIKit
import SwiftUI

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
  static let customDarkGrey = Color(UIColor(rgb: 0xC4C4C4))
  static let customLightGrey = Color(UIColor(rgb: 0xF0F0F0))
  static let customYellow = Color(UIColor(rgb: 0xF7DA20))
  static let customWhite = Color(UIColor(rgb: 0xFAFAFA))
}
