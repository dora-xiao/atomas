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
  @State var pair1: CGPoint = CGPoint(x: 0, y: 0)
  @State var pair2: CGPoint = CGPoint(x: 0, y: 0)
  
  var body: some View {
    ZStack {
      Color.clear
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 0)
            .onEnded { value in
              if(appData.board.count >= 18) {
                self.tapped = CGPoint(x: 0, y: 0)
                self.pair1 = CGPoint(x: 0, y: 0)
                self.pair2 = CGPoint(x: 0, y: 0)
                return
              }
              self.tapped = value.location
              print("Tapped at \(tapped)")
              
              let distanceToCenter = distance(tapped, center)
              if(distanceToCenter > radius+10 || distanceToCenter < radius/2) { // tappable area
                self.tapped = CGPoint(x: 0, y: 0)
                self.pair1 = CGPoint(x: 0, y: 0)
                self.pair2 = CGPoint(x: 0, y: 0)
                return
              }
              
              // Determine where to insert
              let (closestIndex, closestP1, closestP2) = findClosestPair(self.positions, self.tapped)!
              print(closestIndex, closestP1, closestP2)
              self.pair1 = closestP1
              self.pair2 = closestP2
              
              return
              
              let angle = angleForPoint(self.tapped, center: center)
              let previewPositions = arrangeObjectsEquallySpaced(
                numberOfObjects: appData.board.count + 1,
                radius: radius,
                center: center
              )
              let insertIndex = findInsertionIndex(for: angle, in: previewPositions, center: center)
              
              // Insert center element into board
              appData.board.insert(appData.center, at: insertIndex)
              appData.center = spawn(appData: appData)  // Reset center or spawn a new one however you prefer
              
              // Recalculate positions
              self.positions = arrangeObjectsEquallySpaced(
                numberOfObjects: appData.board.count,
                radius: radius,
                center: center
              )
            }
        )
      
      // Restart Button
      Button(action: {
        appData.createAndLoadNewGame()
        self.positions = arrangeObjectsEquallySpaced(
          numberOfObjects: appData.board.count,
          radius: radius,
          center: center
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
      // DEBUG: Detected pair
      Circle()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 50, height: 50)
        .position(x: pair1.x, y: pair1.y)
      Circle()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 50, height: 50)
        .position(x: pair2.x, y: pair2.y)
    }
    .onAppear {
      self.positions = arrangeObjectsEquallySpaced(
        numberOfObjects: appData.board.count,
        radius: radius,
        center: center
      )
    }
  }
  
  func angleForPoint(_ point: CGPoint, center: CGPoint) -> CGFloat {
    let dx = point.x - center.x
    let dy = point.y - center.y
    var angle = atan2(dy, dx)
    if angle < 0 { angle += 2 * .pi }
    return angle
  }
  
  func findInsertionIndex(for angle: CGFloat, in positions: [CGPoint], center: CGPoint) -> Int {
    let angles = positions.map { point -> CGFloat in
      var theta = atan2(point.y - center.y, point.x - center.x)
      if theta < 0 { theta += 2 * .pi }
      return theta
    }
    
    for i in 0..<angles.count {
      let current = angles[i]
      let next = angles[(i + 1) % angles.count]
      let start = current
      let end = next > current ? next : next + 2 * .pi
      
      if angle >= start && angle < end {
        return (i + 1) % angles.count
      }
    }
    
    return 0
  }
}
