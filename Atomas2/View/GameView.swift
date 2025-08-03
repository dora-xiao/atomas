//
//  GameView.swift
//  Atomas2
//
//  Created by Dora Xiao on 8/2/25.
//

import SwiftUI

struct GameView: View {
  @EnvironmentObject var appData : AppData
  let center: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2-40)
  let radius: CGFloat = UIScreen.main.bounds.width/2-60
  
  var body: some View {
    ZStack {
      let positions = arrangeObjectsEquallySpaced(numberOfObjects: appData.board.count, radius: radius, center: center)
      
      // Restart Button
      Button(action: {
        appData.createAndLoadNewGame()
      }) {
        Text("Restart")
      }
      .buttonStyle(.ghost)
      .position(x: 60, y: 30)
      
      // Circle outline
      Circle()
        .stroke(Color.gray, lineWidth: 1)
        .frame(width: UIScreen.main.bounds.width-50, height: UIScreen.main.bounds.width-50)
      
      // TODO: Longest chain highlight
      
      // Elements around circle
      ForEach(0..<positions.count, id: \.self) { i in
        Tile(element: appData.board[i], elements: appData.elements).position(x: positions[i].x, y: positions[i].y)
      }
      
      // Center element
      Tile(element: appData.center, elements: appData.elements)
        .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2-40)
    }
  }
}
