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
  @State var positions: [CGPoint] = []
  @State var tapped: CGPoint = CGPoint(x: 0, y: 0)
  
  var body: some View {
    ZStack {
      Color.clear
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 0)
            .onEnded { value in
              if(appData.board.count >= 18) {
                self.tapped = CGPoint(x: 0, y: 0)
                return
              }
              self.tapped = value.location
              print("Tapped at \(tapped)")
              
              let distanceToCenter = distance(tapped, center)
              if(distanceToCenter > radius+10 || distanceToCenter < radius/2) { // tappable area
                self.tapped = CGPoint(x: 0, y: 0)
                return
              }
              
              // Determine where to insert
              let (closestIndex, midpointAngle) = findClosestPair(self.positions, self.tapped, self.center)!
              let newPositions = arrange(self.appData, self.center, self.radius, closestIndex, midpointAngle)
              self.positions = newPositions
              
              appData.center = spawn(appData: appData)
            }
        )
      
      // Restart Button
      Button(action: {
        appData.createAndLoadNewGame()
        self.positions = arrangeObjectsEquallySpaced(
          numberOfObjects: appData.board.count,
          radius: radius,
          center: center,
          startAngle: 0
        )
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
        Tile(element: appData.board[i], elements: appData.elements)
          .position(x: self.positions[i].x, y: self.positions[i].y)
      }
      
      // Center element
      Tile(element: appData.center, elements: appData.elements)
        .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2-40)
      
      // DEBUG: Tapped spot
      Circle()
        .fill(.red)
        .frame(width: 5, height: 5)
        .position(x: tapped.x, y: tapped.y)
    }
    .onAppear {
      self.positions = arrangeObjectsEquallySpaced(
        numberOfObjects: appData.board.count,
        radius: radius,
        center: center,
        startAngle: 0
      )
    }
  }
}
