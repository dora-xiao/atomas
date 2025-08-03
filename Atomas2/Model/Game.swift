import Foundation
import CoreData

// Puzzle structure in json
struct GameData: Codable {
  let score: Int
  let center: Int
  let board: [Int]
  let moves: Int
  let lastPlus: Int
  let lastMinus: Int
}

var initGame: GameData = GameData(
  score: -1,
  center: -1,
  board: [],
  moves: 0,
  lastPlus: 0,
  lastMinus: 0
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

// Delete all saved data
func deleteAllData(appData: AppData) {
    let context = appData.context
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Game.fetchRequest()
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(batchDeleteRequest)
        try context.save()
        appData.loadGame()
        print("Deleted all game data.")
    } catch {
        print("Failed to delete all game data: \(error)")
    }
}

// Reset current game
func newGame(appData: AppData) {
  let newGame = Game(context: appData.context)
  // Choose random starting board
  let startOptions: [Int] = [1, 2, 3]
  var temp: [Int] = []
  for _ in 0..<6 {
      if let chosen = startOptions.randomElement() {
        temp.append(chosen)
      }
  }
  newGame.board = temp
  try! appData.context.save()
  appData.game = newGame
  appData.board = temp
  appData.score = 0
  appData.center = startOptions.randomElement()!
  appData.lastPlus = 0
  appData.lastMinus = 0
  appData.moves = 0
}

// Spawn next center tile
func spawn(appData: AppData) {
  
}
