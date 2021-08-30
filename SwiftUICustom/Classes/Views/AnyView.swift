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
        let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: buildingBlock)
        var environment = environment
        environment.currentStateNode = newNode
        let view = buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
        newNode.uiView = view
        let holdingView = SwiftUIView()
		insertView(from: holdingView, view)
		return holdingView
	}
	
	func insertView(from normalView: UIView, _ view: UIView) {
        normalView.translatesAutoresizingMaskIntoConstraints = false
		normalView.subviews.forEach { $0.removeFromSuperview() }
		view.translatesAutoresizingMaskIntoConstraints = false
		normalView.addSubview(view)
        normalView.setupFullConstraints(normalView, view)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: controller, buildingBlock: buildingBlock)
        var environment = environment
        environment.currentStateNode = newNode
        let internalView = buildingBlock._toUIView(enclosingController: controller, environment: environment)
        newNode.uiView = internalView
        insertView(from: view, internalView)
	}
}
