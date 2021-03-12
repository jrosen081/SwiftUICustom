//
//  Redrawable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

protocol Redrawable: AnyObject {
	func addListener(_ listener: UpdateDelegate)
	func stopRedrawing()
	func startRedrawing()
	func performAnimation(animation: Animation)
    func reset()
}

class WeakRedrawable {
  weak var redrawable: Redrawable?
  init(redrawable: Redrawable?) {
    self.redrawable = redrawable
  }
}

class Redrawables {
  static var redrawables: [WeakRedrawable] = []
}
