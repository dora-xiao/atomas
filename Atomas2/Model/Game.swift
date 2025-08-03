import Foundation
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
func combine(center: Int, outer: Int) -> Int {
  if(center == -2) { // center = "plus" atom
    return outer + 1
  } else if(center > outer) {
    return center + 1
  } else {
    return outer + 2
  }
}

func distance(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
  let xDistance = point1.x - point2.x
  let yDistance = point1.y - point2.y
  return (xDistance * xDistance + yDistance * yDistance).squareRoot()
}

func angleBetween(from center: CGPoint, to target: CGPoint) -> CGFloat {
  let deltaX = target.x - center.x
  let deltaY = target.y - center.y
  let angleRadians = atan2(deltaY, deltaX)
  return angleRadians * 180 / .pi
}

func findClosestPair(_ points: [CGPoint], _ myPoint: CGPoint, _ centerPoint: CGPoint) -> (Int, CGFloat)? {
  guard points.count >= 2 else {
    return nil // Need at least two points to form an adjacent pair
  }
  
  var closestDistance: CGFloat = .greatestFiniteMagnitude
  var closestPair: (Int, CGFloat)? = nil
  
  for i in 0..<points.count {
    let p1 = points[i]
    let secondIndex = i == points.count - 1 ? 0 : i+1
    let p2 = points[secondIndex]
    
    let midpoint = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    let midpointAngle = angleBetween(from: centerPoint, to: midpoint) // TODO: something is wrong with angle
    let currentDistance = distance(midpoint, myPoint)
    
    if currentDistance < closestDistance {
      closestDistance = currentDistance
      closestPair = (secondIndex, midpointAngle)
    }
  }
  return closestPair
}

func arrange(_ appData: AppData,  _ centerPoint: CGPoint, _ radius: CGFloat, _ closestIndex: Int, _ midpointAngle: CGFloat) -> [CGPoint] {
  appData.board.insert(appData.center, at: closestIndex)
  appData.board = appData.board.wrapped(startingAt: closestIndex)
  print("Inserted \(appData.elements[appData.center]!.symbol) at index \(closestIndex): \(appData.board)")
  
  return arrangeObjectsEquallySpaced(
    numberOfObjects: appData.board.count,
    radius: radius,
    center: centerPoint,
    startAngle: midpointAngle)
}
