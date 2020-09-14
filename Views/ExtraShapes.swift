//
//  ExtraShapes.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct Rectange: Shape {
	public init() {}
	public func path(in rect: CGRect) -> Path {
		return Path(rect: rect)
	}
}

public struct RoundedRectangle: Shape {
	let cornerRadius: CGFloat
	
	public init(cornerRadius: CGFloat) {
		self.cornerRadius = cornerRadius
	}
	
	public func path(in rect: CGRect) -> Path {
		return Path(roundedRect: rect, cornerRadius: self.cornerRadius)
	}
}

public struct Capsule: Shape {
	public init() {}
	
	public func path(in rect: CGRect) -> Path {
		return Path(roundedRect: rect, cornerRadius: min(rect.height, rect.width) / 2)
	}
}

public struct Ellipse: Shape {
	public init() {}
	
	public func path(in rect: CGRect) -> Path {
		return Path(ovalIn: rect)
	}
}


