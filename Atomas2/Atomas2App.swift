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
        self.board = (existingGame.board as? [String])?.compactMap { Int($0) } ?? []
      } else {
        let newGame = Game(context: context)
        newGame.score = -1
        newGame.center = -1
        newGame.board = []
        try context.save()
        self.game = newGame
      }
    } catch {
      print("Failed to fetch or create game: \(error)")
    }
    self.board = [1, 2, 3, 4]
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
