//
//  GameView.swift
//  Atomas2
//
//  Created by Dora Xiao on 8/2/25.
//

import SwiftUI

struct GameView: View {
  @EnvironmentObject var appData : AppData
  
  var body: some View {
    VStack {
      Tile(element: 1, elements: appData.elements)
      Tile(element: 2, elements: appData.elements)
    }
  }
}
