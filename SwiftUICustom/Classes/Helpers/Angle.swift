//
//  Angle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct Angle: Equatable {
	let radians: Double
	
	public init() {
		self.radians = 0
	}
	
	public init(degrees: Double) {
		self.radians = degrees * .pi / 180
	}
	
	public init(radians: Double) {
		self.radians = radians
	}
	
	public static func degrees(_ double: Double) -> Angle {
		return Angle(degrees: double)
	}
	
	public static func radians(_ double:  Double) -> Angle {
		return Angle(radians: double)
	}
}
