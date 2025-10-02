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
  let size: CGFloat = 50
  @State var rotations: [Angle] = []
  @State var tapped: CGPoint = CGPoint(x: 0, y: 0)
  @State var destIndex: Int = 0
  @State var destAngle: Angle = Angle(degrees: 0)
  @State var centerPos: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2-40)
  @State var disabled: Bool = false
  @State var absorbIndex: Int = -1
  
  var body: some View {
    ZStack {
      Color.clear
        .contentShape(Rectangle())
        .gesture(
          DragGesture(minimumDistance: 0)
            .onEnded { value in
              // Ignore tap if disabled
              if(self.disabled) {
                return
              }
              
              self.tapped = value.location
              print("Tapped at \(tapped)")
              
              // Don't allow more than 18 tiles
              if(appData.board.count >= 18) {
                self.tapped = CGPoint(x: 0, y: 0)
                return
              }
              
              // Restrict tappable area
              let didTapCenter = tappedCenter(tapped, center, radius, size)
              let (tileIndex, tileAngle) = tappedTile(tapped, center, rotations, radius, size)
              let (spaceIndex, spaceAngle) = tappedSpace(tapped, center, rotations, radius, size)
              if(appData.prevCenter == -1 && didTapCenter) {
                // Center is element absorbed by previous minus, tapping converts it to a plus
                appData.prevCenter = appData.center
                appData.center = -2
              } else if(appData.center == -3 && tileIndex > -1) {
                // Center is a neutrino, tapping causes copying
                appData.prevCenter = -3
                appData.center = appData.board[tileIndex]
              } else if(appData.center == -1 && tileIndex > -1) {
                // Center is a minus, tapping a tile causes absorption
                appData.prevCenter = -1
                withAnimation(.linear(duration: 0.2)) {
                  self.disabled = true
                  self.absorbIndex = tileIndex
                  let newRotations = absorb(tileIndex, tileAngle, rotations, appData)
                  self.rotations = newRotations
                } completion: {
                  appData.center = appData.board[tileIndex]
                  self.appData.board.remove(at: tileIndex)
                  self.rotations.remove(at: tileIndex)
                  self.absorbIndex = -1
                  self.disabled = false
                }
              } else if((appData.center > 0 || appData.center == -2) && spaceIndex > -1) {
                // Center is an element tile or a plus, tapping a space causes insertion
                appData.prevCenter = appData.center
                withAnimation(.linear(duration: 0.2)) {
                  self.disabled = true
                  // Slide to rearrange
                  let (destIndex, destAngle, newRotations) = insert(spaceIndex, spaceAngle, rotations, appData)
                  self.destIndex = destIndex
                  self.destAngle = destAngle
                  self.rotations = newRotations
                  self.centerPos = getCirclePoint(self.center, self.radius, self.destAngle.radians)
                } completion: {
                  // Add center to board/rotations and spawn a new center
                  self.appData.board.insert(appData.center, at: self.destIndex)
                  self.rotations.insert(self.destAngle, at: self.destIndex)
                  self.appData.center = spawn(appData: self.appData)
                  self.centerPos = self.center
                  
                  // Check for combining
                  let (didCombine, animRotations, newBoard, newRotations, combinedVal) = combine(appData, rotations)
                  if(didCombine) {
                    withAnimation(.linear(duration: 0.2)) {
                      self.rotations = animRotations
                    } completion: {
                      self.rotations = newRotations
                      self.appData.board = newBoard
                      self.disabled = false
                    }
                  } else {
                    self.disabled = false
                  }
                }
              } else { // No valid combinations of taps and game states
                self.tapped = CGPoint(x: 0, y: 0)
                return
              }
            }
        )
      
      // Restart Button
      Button(action: {
        appData.createAndLoadNewGame()
        self.rotations = initArrange(appData.board.count)
      }) {
        Text("Restart")
      }
      .buttonStyle(.ghost)
      .position(x: 60, y: 30)
      
      // Circle outline
      Circle()
        .stroke(Color.gray, lineWidth: 1)
        .frame(width: UIScreen.main.bounds.width-50, height: UIScreen.main.bounds.width-50)
      
      // Elements around circle
      ForEach(0..<rotations.count, id: \.self) { i in
        Tile(element: appData.board[i], elements: appData.elements, rotation: rotations[i], size: size)
          .offset(x: i == absorbIndex ? 0 : radius )
          .rotationEffect(rotations[i])
      }
      
      // Center element
      Tile(element: appData.center, elements: appData.elements, rotation: Angle(degrees: 0), size: size)
        .position(centerPos)
      
      // DEBUG: Tapped spot
      //      Circle()
      //        .fill(.red)
      //        .frame(width: 5, height: 5)
      //        .position(x: tapped.x, y: tapped.y)
    }
    .onAppear {
      self.rotations = initArrange(appData.board.count)
    }
  }
}

/// Determine whether the tapped location was the center
func tappedCenter(_ tapped: CGPoint, _ center: CGPoint, _ radius: CGFloat, _ size: CGFloat) -> Bool {
  let distanceToCenter = distance(tapped, center)
  return distanceToCenter < size
}

/// Determine whether the tapped location was a valid tile, and if so, return the index and angle that was tapped
func tappedTile(
  _ tapped: CGPoint,
  _ center: CGPoint,
  _ rotations: [Angle],
  _ radius: CGFloat,
  _ size: CGFloat
) -> (Int, Angle) {
  let distanceToCenter = distance(tapped, center)
  if distanceToCenter < radius * 0.70 || distanceToCenter > radius + size / 2 {
    return (-1, Angle(degrees: 0))
  }
  
  // Compute angle of tap relative to circle center
  let dx = tapped.x - center.x
  let dy = tapped.y - center.y
  var tapAngle = atan2(dy, dx)   // radians, from -π to π
  
  if tapAngle < 0 { tapAngle += 2 * .pi }
  var closestIndex = 0
  var found = false
  var minDelta = CGFloat.greatestFiniteMagnitude
  
  for (i, angle) in rotations.enumerated() {
    var candidate = CGFloat(angle.radians)
    if candidate < 0 { candidate += 2 * .pi }
    let delta = abs(atan2(sin(tapAngle - candidate), cos(tapAngle - candidate)))
    let arcLength = radius * delta
    if arcLength < size / 2 && arcLength < minDelta {
      minDelta = arcLength
      closestIndex = i
      found = true
    }
  }
  
  return found ? (closestIndex, rotations[closestIndex]) : (-1, Angle(degrees: 0))
}

/// Determine whether the tapped location was a valid space, and if so, return the index and angle to insert at
func tappedSpace(_ tapped: CGPoint, _ center: CGPoint, _ rotations: [Angle], _ radius: CGFloat, _ size: CGFloat) -> (Int, Angle) {
  let distanceToCenter = distance(tapped, center)
  if(distanceToCenter < radius * 0.70 || distanceToCenter > radius + size / 2) {
    return (-1, Angle(degrees: 0))
  }
  
  // Find index and angle to insert at
  var closestResult: (Int, Angle) = (-1, Angle(degrees: 0))
  guard rotations.count >= 2 else { return closestResult }
  let tapAngle = angleBetween(from: center, to: tapped)
  var closestDistance: CGFloat = .greatestFiniteMagnitude
  
  for i in 0..<rotations.count {
    let j = (i + 1) % rotations.count
    let angle1 = rotations[i].radians
    let angle2 = rotations[j].radians
    let mid = midpointAngle(angle1, angle2)
    let dist = angularDistance(tapAngle, mid)
    if dist < closestDistance {
      closestDistance = dist
      closestResult = (j, Angle(radians: mid))
    }
  }
  return closestResult
}
