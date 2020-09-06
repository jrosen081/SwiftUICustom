//
//  ColorView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public struct ColorView<Content: View>: View {
	let color: UIColor?
	let view: Content
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = self.view.toUIView(enclosingController: enclosingController)
		view.tintColor = color ?? view.tintColor
		return view
	}
}

public extension View {
	func foregroundColor(_ color: UIColor?) -> ColorView<Self> {
		return ColorView(color: color, view: self)
	}
}
