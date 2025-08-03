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
  @Published var board: [Int] = []
  @Published var center: Int = 0
  @Published var lastPlus: Int = 0
  @Published var lastMinus: Int = 0
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
        self.board = existingGame.board!
        self.moves = Int(existingGame.moves)
        self.lastPlus = Int(existingGame.lastPlus)
        self.lastMinus = Int(existingGame.lastMinus)
      } else {
        newGame(appData: self)
      }
    } catch {
      print("Failed to fetch or create game: \(error)")
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
    _appData = StateObject(wrappedValue: AppData(context: context))
  }
  
  var body: some Scene {
    WindowGroup {
      NavigationView().environmentObject(appData)
    }
  }
}
