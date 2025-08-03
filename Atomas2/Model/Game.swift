import Foundation
import CoreData

// Puzzle structure in json
struct GameData: Codable {
  let score: Int
  let center: Int
  let board: [Int]
}

var initGame: GameData = GameData(
  score: -1,
  center: -1,
  board: []
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

