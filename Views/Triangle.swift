//
//  Triangle.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/12/20.
//

import Foundation

public struct Triangle: Shape {
	public init() {}
	
	public func path(in rect: CGRect) -> Path {
		Path { path in
			path.move(to: CGPoint(x: rect.midX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
		}
	}
}
