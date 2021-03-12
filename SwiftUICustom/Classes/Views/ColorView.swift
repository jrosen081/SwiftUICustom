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
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = color
		let view = self.view.__toUIView(enclosingController: enclosingController, environment: newEnvironment)
		return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = color
		self.view._redraw(view: view, controller: controller, environment: newEnvironment)
	}
}

public extension View {
	
}
