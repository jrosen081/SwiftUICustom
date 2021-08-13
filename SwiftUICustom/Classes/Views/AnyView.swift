//
//  AnyView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/1/20.
//

import Foundation

public struct AnyView: View {    
    let buildingBlock: _BuildingBlock
	
	public init<S: View>(_ view: S) {
		buildingBlock = view
	}
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = buildingBlock
        let view = buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
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
        environment.currentStateNode.buildingBlock = buildingBlock
        environment.currentStateNode.environment = environment
        let internalView = buildingBlock._toUIView(enclosingController: controller, environment: environment)
        environment.currentStateNode.uiView = internalView
        insertView(from: view, internalView)
	}
}
