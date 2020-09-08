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
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = color
		let view = self.view.toUIView(enclosingController: enclosingController, environment: newEnvironment)
		return view
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = color
		self.view.redraw(view: view, controller: controller, environment: newEnvironment)
	}
}

public extension View {
	func foregroundColor(_ color: UIColor?) -> ColorView<Self> {
		return ColorView(color: color, view: self)
	}
}