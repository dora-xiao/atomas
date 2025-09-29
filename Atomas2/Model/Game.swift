import Foundation
import SwiftUI
import CoreData
import CoreGraphics

// Puzzle structure in json
struct GameData: Codable {
  let score: Int
  let center: Int
  let board: [Int]
  let moves: Int
  let lastPlus: Int
}

var initGame: GameData = GameData(
  score: -1,
  center: -1,
  board: [],
  moves: 0,
  lastPlus: 0,
)

// Transformer for board
@objc(ArrayIntTransformer)
class ArrayIntTransformer: NSSecureUnarchiveFromDataTransformer {
  override class var allowedTopLevelClasses: [AnyClass] {
    return [NSArray.self, NSNumber.self]
  }
  
  static let name = NSValueTransformerName(rawValue: String(describing: ArrayIntTransformer.self))
  
  public static func register() {
    let transformer = ArrayIntTransformer()
    ValueTransformer.setValueTransformer(transformer, forName: name)
  }
}

struct ElementJson: Codable {
  let symbol: String
  let name: String
  let color: String
}

struct Element {
  let symbol: String
  let name: String
  let color: Int
}

func hexStringToInt(_ hexString: String) -> Int? {
  // Remove the '#' prefix if it exists
  let cleanHexString = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString
  
  // Attempt to convert the hexadecimal string to an Int using radix 16
  return Int(cleanHexString, radix: 16)
}

// Read elements json
func loadElements() -> [Int: Element] {
  guard let url = Bundle.main.url(forResource: "elements", withExtension: "json") else {
    print("elements.json not found in bundle")
    return [:]
  }
  
  do {
    let data = try Data(contentsOf: url)
    let decoder = JSONDecoder()
    let elementsById = try decoder.decode([String: ElementJson].self, from: data)
    var result: [Int: Element] = [:]
    for (key, value) in elementsById {
      result[Int(key)!] = Element(
        symbol: value.symbol,
        name: value.name,
        color: hexStringToInt(value.color)!
      )
    }
    print("Loaded elements")
    return result
  } catch {
    print("Failed to decode elements.json: \(error)")
    return [:]
  }
}

extension Array {
  func wrapped(startingAt index: Int) -> [Element] {
    guard !self.isEmpty else { return [] } // Handle empty array
    let effectiveIndex = (index % self.count + self.count) % self.count // Handle negative or out-of-bounds indices
    
    let suffix = self.suffix(from: effectiveIndex)
    let prefix = self.prefix(upTo: effectiveIndex)
    
    return Array(suffix) + Array(prefix)
  }
}

// Spawn next center tile
func spawn(appData: AppData) -> Int {
  return -1
  appData.moves += 1
  appData.lastPlus += 1
  if(appData.moves % 20 == 0 && appData.moves > 18) {
    return -1 // minus
  } else if(appData.lastPlus > 4) {
    appData.lastPlus = 0
    return -2 // plus
  } else if(appData.score > 1500 && Int.random(in: 1...60) == 1) {
    return -3 // neutrinos
  } else {
    let rangeLower = Int(appData.moves / 40)
    let rangeOptions = [rangeLower+1, rangeLower+2, rangeLower+3]
    for b in Set(appData.board.filter{!rangeOptions.contains($0)}) {
      if(Int.random(in: 1...appData.board.count) == 1) {
        return b // board item not in range
      }
    }
    if(Int.random(in: 1...5) == 1) {
      return -2 // early plus
    }
    let chosenInRange = rangeOptions.randomElement()!
    return chosenInRange
  }
}

// Accepts the combining atom numbers and returns the resulting atom
func combineValue(center: Int, outer: Int) -> Int {
  if(center == -2) { // center = "plus" atom
    return outer + 1
  } else if(center > outer) {
    return center + 1
  } else {
    return outer + 2
  }
}

/// Returns a list of tuples of the fixed index and the board states
func combine(_ board: [Int], _ rotations: [Angle]) -> [(Int, [Int], [Angle])] {
  
  return []
}

func distance(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
  let xDistance = point1.x - point2.x
  let yDistance = point1.y - point2.y
  return (xDistance * xDistance + yDistance * yDistance).squareRoot()
}

func angleBetween(from: CGPoint, to: CGPoint) -> CGFloat {
  atan2(to.y - from.y, to.x - from.x)
}

func normalizeAngle(_ angle: Double) -> Double {
  let twoPi = 2 * Double.pi
  var a = angle.truncatingRemainder(dividingBy: twoPi)
  if a < 0 { a += twoPi }
  return a
}

func angularDistance(_ a1: CGFloat, _ a2: Double) -> CGFloat {
  let diff = abs(CGFloat(normalizeAngle(Double(a1) - a2)))
  return min(diff, 2 * .pi - diff)
}

/// Midpoint between two angles, respecting wrap-around
func midpointAngle(_ a1: Double, _ a2: Double) -> Double {
  let a1n = normalizeAngle(a1)
  let a2n = normalizeAngle(a2)
  let diff = normalizeAngle(a2n - a1n)
  
  if diff <= .pi {
    // Normal case: a2 is ahead of a1 in CCW direction
    return normalizeAngle(a1n + diff / 2)
  } else {
    // Take the shorter arc the other way around
    let backDiff = 2 * .pi - diff
    return normalizeAngle(a2n + backDiff / 2)
  }
}

//
func initArrange(_ count: Int) -> [Angle] {
  let increment = 2 * Double.pi / Double(count)
  var result: [Angle] = Array(repeating: .radians(0), count: count)
  
  for i in 0..<result.count {
    result[i] = Angle(radians: Double(i) * increment)
  }
  
  return result
}


/// Evenly space objects around circle so that `fixedIndex` is exactly at `fixedAngle`
func arrange(
  prevRotations: [Angle],
  fixedIndex: Int,
  fixedAngle: Angle,
  appData: AppData
) -> [Angle] {
  let increment = 2 * Double.pi / Double(prevRotations.count+1)
  var result: [Angle] = Array(repeating: .radians(0), count: prevRotations.count+1)
  result[fixedIndex] = fixedAngle
  var prevRotationsInserted = prevRotations
  prevRotationsInserted.insert(fixedAngle, at: fixedIndex)
    
  for i in 1..<result.count {
    let j = (i + fixedIndex) % result.count
    var newRotation = Angle(radians: fixedAngle.radians + Double(i) * increment)
    if(newRotation.degrees - prevRotationsInserted[j].degrees > 180) {
      newRotation.degrees -= 360
    } else if(newRotation.degrees - prevRotationsInserted[j].degrees < -180) {
      newRotation.degrees += 360
    }
    result[j] = newRotation
  }
  
  return result
}

func getCirclePoint(_ center: CGPoint, _ radius: CGFloat, _ angleRadians: CGFloat) -> CGPoint {
  let x = center.x + radius * cos(angleRadians)
  let y = center.y + radius * sin(angleRadians)
  return CGPoint(x: x, y: y)
}

func insert(
  _ closestIndex: Int,
  _ midpointAngle: Angle,
  _ rotations: [Angle],
  _ appData: AppData
) -> (Int, Angle, [Angle]) {
  appData.board.insert(appData.center, at: closestIndex)
  
  let increment = 2 * Double.pi / Double(rotations.count+1)
  var newRotations: [Angle] = Array(repeating: .radians(0), count: rotations.count+1)
  newRotations[closestIndex] = midpointAngle
  var rotationsInserted = rotations
  rotationsInserted.insert(midpointAngle, at: closestIndex)
    
  for i in 1..<newRotations.count {
    let j = (i + closestIndex) % newRotations.count
    var newRotation = Angle(radians: midpointAngle.radians + Double(i) * increment)
    if(newRotation.degrees - rotationsInserted[j].degrees > 190) {
      newRotation.degrees -= 360
    } else if(newRotation.degrees - rotationsInserted[j].degrees < -190) {
      newRotation.degrees += 360
    }
    newRotations[j] = newRotation
  }
  
  newRotations.remove(at: closestIndex)
  appData.board.remove(at: closestIndex)
  
  return (closestIndex, midpointAngle, newRotations)
}


func absorb(_ tileIndex: Int, _ tileAngle: Angle, _ rotations: [Angle], _ appData: AppData) -> [Angle] {
  let absorbed = appData.board.remove(at: tileIndex)
  
  let increment = 2 * Double.pi / Double(rotations.count-1)
  var newRotations: [Angle] = Array(repeating: .radians(0), count: rotations.count)
  newRotations[tileIndex] = tileAngle
  appData.board.insert(absorbed, at: tileIndex)
    
  for i in 1..<newRotations.count {
    let j = (i + tileIndex) % newRotations.count
    var newRotation = Angle(radians: tileAngle.radians + Double(i) * increment)
    if(newRotation.degrees - rotations[j].degrees > 190) {
      newRotation.degrees -= 360
    } else if(newRotation.degrees - rotations[j].degrees < -190) {
      newRotation.degrees += 360
    }
    newRotations[j] = newRotation
  }
  
  return newRotations
}
