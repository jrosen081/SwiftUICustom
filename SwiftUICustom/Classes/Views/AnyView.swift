//
//  AnyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct AnyView: View {
    public func _isEqual(toSameType other: Self, environment: EnvironmentValues) -> Bool {
        return false
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        Int.random(in: 0..<Int.max).hash(into: &hasher)
    }
    
	let viewCreator: (UIViewController, EnvironmentValues) -> UIView
	
	public init<S: View>(_ view: S) {
		viewCreator = view.__toUIView(enclosingController:environment:)
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
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
