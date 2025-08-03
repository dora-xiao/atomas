import Foundation
import CoreData

@objc(Game)
public class Game: NSManagedObject {}

extension Game {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var score: Int32
    @NSManaged public var center: Int32
    @NSManaged public var board: [Int]?
}
