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
        let view = buildingBlock._toUIView(enclosingController: enclosingController, environment: environment)
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
        insertView(from: view, buildingBlock._toUIView(enclosingController: controller, environment: environment))
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        buildingBlock._requestedSize(within: size, environment: environment)
    }
}
