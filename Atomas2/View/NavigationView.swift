import SwiftUI

struct NavigationView: View {
  @EnvironmentObject var appData : AppData
  
  var body: some View {
    switch (appData.currView) {
    case .game: GameView().environmentObject(self.appData)
    case .temp: TempView().environmentObject(self.appData)
    }
  }
}
