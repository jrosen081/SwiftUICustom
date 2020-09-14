//
//  Redrawable.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

protocol Redrawable {
	func addListener(_ listener: UpdateDelegate)
	func stopRedrawing()
	func startRedrawing()
	func performAnimation(animation: Animation)
}
