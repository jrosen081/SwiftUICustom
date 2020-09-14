//
//  ClipShapedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/12/20.
//

import Foundation

public struct ClipShapedView<ShapeGeneric: Shape, Content: View>: View {
	let shape: ShapeGeneric
	let content: Content
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let clippedView = ClippedView(shapeGeneric: self.shape)
		let view = self.content._toUIView(enclosingController: enclosingController, environment: environment)
		clippedView.addSubview(view)
		clippedView.setupFullConstraints(clippedView, view)
		return clippedView
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let clippedView = view as? ClippedView<ShapeGeneric> else { return }
		self.content._redraw(view: clippedView.subviews[0], controller: controller, environment: environment)
		clippedView.shapeGeneric = self.shape
	}
}

class ClippedView<ShapeGeneric: Shape>: SwiftUIView {
	var shapeGeneric: ShapeGeneric {
		didSet {
			layoutIfNeeded()
		}
	}
	
	lazy var shapeLayer: CAShapeLayer = CAShapeLayer()
	
	init(shapeGeneric: ShapeGeneric) {
		self.shapeGeneric = shapeGeneric
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layer.mask = self.shapeLayer
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.shapeLayer.path = self.shapeGeneric.path(in: self.bounds).cgPath
	}
}

public extension View {
	func clipShape<S: Shape>(_ shape: S) -> ClipShapedView<S, Self> {
		return ClipShapedView(shape: shape, content: self)
	}
}
