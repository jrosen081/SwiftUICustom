//
//  AnyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct AnyView: View {
	let viewCreator: (UIViewController, EnvironmentValues) -> UIView
	
	@State var view: UIView = UIView()
	
	public init<S: View>(_ view: S) {
		viewCreator = view.toUIView(enclosingController:environment:)
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = viewCreator(enclosingController, environment)
		insertView(view)
		return view
	}
	
	func insertView(_ view: UIView) {
		view.subviews.forEach { $0.removeFromSuperview() }
		view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			view.topAnchor.constraint(equalTo: self.view.topAnchor)
		])
	}
	
	public func redraw(controller: UIViewController, environment: EnvironmentValues) {
		insertView(viewCreator(controller, environment))
	}
}
