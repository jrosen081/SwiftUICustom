//
//  Animatable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/22/20.
//

import Foundation

public protocol Animatable {
  associatedtype AnimatedData: VectorArithmetic
  var animatedData: AnimatedData { get set }
}



public protocol VectorArithmetic : AdditiveArithmetic {
  var magnitudeSquared: Double { get }
  mutating func scale(by: Double)
}

extension Int: VectorArithmetic {
  public var magnitudeSquared: Double { return Double(self * self)}
  
  public mutating func scale(by double: Double) {
    self *= Int(double.rounded())
  }
}


class AnimatedView<AnimatedData: VectorArithmetic>: SwiftUIView {
  var animatedData: AnimatedData
  
  
  init(animatedData: AnimatedData) {
    self.animatedData = animatedData
    super.init(frame: .zero)
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func updateToValue(data: AnimatedData, time: Double, renderingFunction: (AnimatedData, UIView) -> ()) {
    
    let distanceToChange = data.magnitudeSquared - self.animatedData.magnitudeSquared
    let scale = distanceToChange / time
    Timer.scheduledTimer(withTimeInterval: time / distanceToChange, repeats: true) { timer in
      self.animatedData.scale(by: scale)
      if (self.animatedData == data) {
        timer.invalidate()
      }
    }
  }
  
}
