//
//  Shape.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

public protocol Shape: View {
	typealias Path = UIBezierPath
	func path(in rect: CGRect) -> Path
}

public extension Shape {
	var body: AnyView {
		return AnyView(UIViewWrapper(view: ShapeSwiftUIView(shape: self)))
	}
	
	func stroke(lineWidth: CGFloat) -> StrokedView<Self> {
		return StrokedView(shape: self, width: lineWidth)
	}
	
	func fill() -> FilledView<Self> {
		return FilledView(shape: self)
	}
}

public struct StrokedView<ShapeGeneric: Shape>: View {
	let shape: ShapeGeneric
	let width: CGFloat
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = ShapeSwiftUIView(shape: self.shape)
		view.isFilled = false
		view.tintColor = .black
		view.shapeLayer.lineWidth = self.width
		view.shapeLayer.fillColor = nil
		return view
	}
}

public struct FilledView<ShapeGeneric: Shape>: View {
	let shape: ShapeGeneric
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController) -> UIView {
		let view = ShapeSwiftUIView(shape: self.shape)
		view.isFilled = true
		view.tintColor = .black
		view.shapeLayer.strokeColor = nil
		return view
	}
}

internal class ShapeSwiftUIView<ShapeGeneric: Shape>: SwiftUIView {
	var isFilled: Bool = false
	
	override var tintColor: UIColor! {
		didSet {
			if isFilled {
				self.shapeLayer.fillColor = tintColor.cgColor
			} else {
				self.shapeLayer.strokeColor = tintColor.cgColor
			}
		}
	}
	
	let shape: ShapeGeneric
	lazy var shapeLayer: CAShapeLayer = {
		let layer = CAShapeLayer()
		layer.lineWidth = 5
		layer.strokeColor = UIColor.black.cgColor
		return layer
	}()
	
	init(shape: ShapeGeneric) {
		self.shape = shape
		super.init(frame: .zero)
		self.layer.addSublayer(self.shapeLayer)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.shapeLayer.path = self.shape.path(in: self.bounds).cgPath
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension UIBezierPath {
	convenience init(_ creator: (inout UIBezierPath) -> ()) {
		var path = UIBezierPath()
		creator(&path)
		self.init(cgPath: path.cgPath)
	}
}
