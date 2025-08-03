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
    ZStack {
      let _ = print("Board: ", appData.board)
      let positions = arrangeObjectsEquallySpaced(numberOfObjects: appData.board.count, radius: UIScreen.main.bounds.width/2-60, center: CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2-40))
      
      Circle()
        .stroke(Color.gray, lineWidth: 1)
        .frame(width: UIScreen.main.bounds.width-50, height: UIScreen.main.bounds.width-50)
      
      ForEach(0..<positions.count, id: \.self) { i in
        Tile(element: appData.board[i], elements: appData.elements).position(x: positions[i].x, y: positions[i].y)
      }
      
      Button(action: {
        newGame(appData: appData)
      }) {
        Text("Restart")
      }
      .buttonStyle(.ghost)
      .position(x: 60, y: 30)
    }
  }
}
