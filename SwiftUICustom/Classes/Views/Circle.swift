//
//  Circle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct Circle: Shape {
	
	public init() {}
	
	public func path(in rect: CGRect) -> Path {
		Path(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: min(rect.width, rect.height) / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
	}
	
	public func redraw(controller: UIViewController, environment: EnvironmentValues) {
		// Do nothing rn
	}
}

struct RightArrow: Shape {
	
	func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: rect.origin)
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
		}
	}
}
