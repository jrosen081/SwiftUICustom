//
//  TransformedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/13/20.
//

import Foundation

public struct TransformedView<Content: View>: View {
	let content: Content
	let transform: CGAffineTransform
	let anchorPoint: CGPoint
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let holdingView = SwiftUIView(frame: .zero)
		holdingView.translatesAutoresizingMaskIntoConstraints = false
		let view = self.content._toUIView(enclosingController: enclosingController, environment: environment)
		view.layer.anchorPoint = self.anchorPoint
		view.transform  = self.transform
		holdingView.addSubview(view)
		holdingView.setupFullConstraints(holdingView, view)
		return holdingView
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		let view = internalView.subviews[0]
		self.content._redraw(view: view, controller: controller, environment: environment)
		view.layer.anchorPoint = self.anchorPoint
		let animations = {
			view.transform  = self.transform
		}
		if let animation = environment.currentAnimation {
			UIView.animate(withDuration: animation.duration, delay: animation.delay, options: animation.animationOptions, animations: animations)
		} else {
			animations()
		}
	}
}

public extension View {
	typealias AnchorPoint = CGPoint
	func rotationEffect(_ angle: Angle, anchorPoint: AnchorPoint = .center) -> TransformedView<Self> {
		return TransformedView(content: self, transform: CGAffineTransform(rotationAngle: CGFloat(angle.radians)), anchorPoint: anchorPoint)
	}
	
	func transformEffect(_ transform: CGAffineTransform) -> TransformedView<Self> {
		return TransformedView(content: self, transform: transform, anchorPoint: .center)
	}
}

public extension CGPoint {
	static let bottom = CGPoint(x: 1, y: 0.5)
	static let bottomLeading = CGPoint(x: 1, y: 0)
	static let bottomTrailing = CGPoint(x: 1, y: 1)
	static let top = CGPoint(x: 0, y: 0.5)
	static let topLeading = CGPoint(x: 0, y: 0)
	static let topTrailing = CGPoint(x: 0, y: 1)
	static let center = CGPoint(x: 0.5, y: 0.5)
	static let leading = CGPoint(x: 0.5, y: 0)
	static let trailing = CGPoint(x: 0.5, y: 1)
}
