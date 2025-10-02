import SwiftUI
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    ArrayIntTransformer.register()
    return true
  }
}

enum Views:Int {
  case game
}

// Environment variable for whole app
class AppData: ObservableObject {
  @Published var currView: Views = Views.game
  @Published var prevViews: [Views] = []
  @Published var score: Int = 0
  @Published var board: [Int] = [1, 1, 1, 1, 1, 1]
  @Published var center: Int = 1
  @Published var prevCenter: Int = 1
  @Published var lastPlus: Int = 0
  @Published var moves: Int = 0
  
  let context: NSManagedObjectContext
  var elements: [Int: Element] = [:]
  var game: Game?
  
  init(context: NSManagedObjectContext) {
    self.context = context
    self.loadGame()
    self.elements = loadElements()
  }
  
  func loadGame() {
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    do {
      let results = try context.fetch(fetchRequest)
      if let existingGame = results.first {
        self.game = existingGame
        self.score = Int(existingGame.score)
        self.center = Int(existingGame.center)
        self.board = existingGame.board ?? []
        self.moves = Int(existingGame.moves)
        self.lastPlus = Int(existingGame.lastPlus)
        print("Loaded game: Score = \(self.score), Board = \(self.board), Center = \(self.center), Moves = \(self.moves), lastPlus = \(self.lastPlus)")
      } else {
        createAndLoadNewGame()
      }
    } catch {
      print("Failed to load game: \(error)")
    }
  }
  
  
  func deleteAllData() {
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    do {
      let games = try context.fetch(fetchRequest)
      for obj in games {
        context.delete(obj)
      }
      try context.save()
      self.game = nil
      print("Deleted all game data.")
    } catch {
      print("Failed to delete all game data: \(error)")
    }
  }
  
  
  func createAndLoadNewGame() {
    // Delete all existing games first
    let fetchRequest: NSFetchRequest<Game> = Game.fetchRequest()
    do {
      let existingGames = try context.fetch(fetchRequest)
      for game in existingGames {
        context.delete(game)
      }
    } catch {
      print("Failed to fetch old games for deletion: \(error)")
    }
    
    // Create new game
    let newGame = Game(context: self.context)
    let startOptions: [Int] = [1, 2, 3]
    var temp: [Int] = []
    for _ in 0..<6 {
      if let chosen = startOptions.randomElement() {
        temp.append(chosen)
      }
    }
    newGame.board = temp
    newGame.center = Int32(startOptions.randomElement()!)
    newGame.score = 0
    newGame.lastPlus = 0
    newGame.moves = 0
    
    do {
      try self.context.save()
      self.game = newGame
      self.board = temp
      self.score = 0
      self.center = Int(newGame.center)
      self.lastPlus = 0
      self.moves = 0
      
      print("Started new game: Score = \(self.score), Board = \(self.board), Center = \(self.center), Moves = \(self.moves), lastPlus = \(self.lastPlus)")
    } catch {
      print("Failed to save new game: \(error)")
    }
  }
  
  func printAllSavedGames() {
      let request: NSFetchRequest<Game> = Game.fetchRequest()
      do {
          let games = try context.fetch(request)
          print("Found \(games.count) saved games:")
          for game in games {
              print("Game: Score = \(game.score)")
          }
      } catch {
          print("Failed to fetch saved games: \(error)")
      }
  }

  
}

@main
struct Atomas2App: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  let persistenceController = PersistenceController.shared
  @StateObject private var appData: AppData
  
  init() {
    let context = persistenceController.container.viewContext
    let data = AppData(context: context)
    _appData = StateObject(wrappedValue: data)
//    data.deleteAllData()
  }
  
  var body: some Scene {
    WindowGroup {
      NavigationView().environmentObject(appData)
    }
  }
}
