//
//  AnyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct AnyView: View {
	let viewCreator: (UIViewController, EnvironmentValues) -> UIView
	
	public init<S: View>(_ view: S) {
		viewCreator = view._toUIView(enclosingController:environment:)
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = viewCreator(enclosingController, environment)
		insertView(from: SwiftUIView(), view)
		return view
	}
	
	func insertView(from normalView: UIView, _ view: UIView) {
		normalView.subviews.forEach { $0.removeFromSuperview() }
		view.translatesAutoresizingMaskIntoConstraints = false
		normalView.addSubview(view)
		NSLayoutConstraint.activate([
			view.bottomAnchor.constraint(equalTo: normalView.bottomAnchor),
			view.leadingAnchor.constraint(equalTo: normalView.leadingAnchor),
			view.trailingAnchor.constraint(equalTo: normalView.trailingAnchor),
			view.topAnchor.constraint(equalTo: normalView.topAnchor)
		])
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		insertView(from: view, viewCreator(controller, environment))
	}
}
