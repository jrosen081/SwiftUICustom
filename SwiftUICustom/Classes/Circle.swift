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
}
