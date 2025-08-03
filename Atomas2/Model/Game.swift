import Foundation
import CoreData

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

// Spawn next center tile
func spawn(appData: AppData) -> Int {
  appData.moves += 1
  appData.lastPlus += 1
  if(appData.moves % 20 == 0 && appData.moves > 18) {
    print("Spawned minus")
    return -1 // minus
  } else if(appData.lastPlus > 4) {
    appData.lastPlus = 0
    print("Spawned plus")
    return -2 // plus
  } else if(appData.score > 1500 && Int.random(in: 1...60) == 1) {
    print("Spawned neutrino")
    return -3 // neutrinos
  } else {
    let rangeLower = Int(appData.moves / 40)
    let rangeOptions = [rangeLower+1, rangeLower+2, rangeLower+3]
    print("Spawn range: \(rangeOptions)")
    for b in Set(appData.board.filter{!rangeOptions.contains($0)}) {
      if(Int.random(in: 1...appData.board.count) == 1) {
        print("Spawned \(b)")
        return b // board item not in range
      }
    }
    if(Int.random(in: 1...5) == 1) {
      print("Spawned plus")
      return -2 // early plus
    }
    let chosenInRange = rangeOptions.randomElement()!
    print("Spawned \(chosenInRange)")
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
