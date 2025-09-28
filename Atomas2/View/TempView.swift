//
//  TempView.swift
//  Atomas2
//
//  Created by Dora Xiao on 9/27/25.
//

import SwiftUI

struct TempView: View {
  @State private var rotationAngles: [Double] = [0.0, 30.0, 60.0, 90.0]
  let radius: CGFloat = UIScreen.main.bounds.width/2-60
  let ct: Int = 4
  
  var body: some View {
    VStack {
      Button("Click Me") {
        withAnimation(.linear(duration: 1)){
          for i in 0..<ct {
            rotationAngles[i] += 20
          }
        }
      }
      ZStack {
        Color.clear
          .contentShape(Rectangle())
        ForEach(0..<ct) { i in
          Circle()
            .fill(Color.blue)
            .frame(width: 50, height: 50)
            .offset(x: radius)
            .rotationEffect(Angle(degrees: rotationAngles[i]))
        }
      }
    }
  }
}
