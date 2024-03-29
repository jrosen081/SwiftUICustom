//
//  BorderedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation


public struct BorderedView<Content: View>: View {
	let content: Content
	let width: CGFloat
	let color: UIColor
	
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = self.content
		let view = self.content._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = view
		view.layer.borderWidth = self.width
		view.layer.borderColor = self.color.cgColor
		return view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		content._redraw(view: view, controller: controller, environment: environment)
	}
}

public extension View {
	func border(_ color: UIColor, lineWidth: CGFloat = 1) -> BorderedView<Self> {
		return BorderedView(content: self, width: lineWidth, color: color)
	}
}
