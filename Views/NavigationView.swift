//
//  NavigationView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationView<Content: View>: View {
	let viewBuilder: Content
	
	public init(_ viewBuilder: () -> Content) {
		self.viewBuilder = viewBuilder()
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		enclosingController.navigationController?.isNavigationBarHidden = false
		return self.viewBuilder.__toUIView(enclosingController: enclosingController, environment: environment)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		self.viewBuilder._redraw(view: view, controller: controller, environment: environment)
	}
}
