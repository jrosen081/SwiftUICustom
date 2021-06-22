//
//  Shape.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation


public typealias Path = UIBezierPath

public protocol Shape: View {
	func path(in rect: CGRect) -> Path
}

public extension Shape {
	var body: Self {
		return self
	}
    
	func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let shape = ShapeSwiftUIView(shape: self)
		shape.shapeLayer.fillColor = (environment.foregroundColor ?? environment.defaultForegroundColor).cgColor
		return shape
	}
	
	func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let shape = view as? ShapeSwiftUIView<Self> else { return }
		shape.shapeLayer.fillColor = (environment.foregroundColor ?? environment.defaultForegroundColor).cgColor
	}
	
	func stroke(lineWidth: CGFloat) -> StrokedView<Self> {
		return StrokedView(shape: self, width: lineWidth)
	}
	
	func fill() -> FilledView<Self> {
		return FilledView(shape: self)
	}
    
    func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size
    }
}

extension Path: Shape {
	public func path(in rect: CGRect) -> Path {
		return self
	}
}

public struct StrokedView<ShapeGeneric: Shape>: View {
	let shape: ShapeGeneric
	let width: CGFloat
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = ShapeSwiftUIView(shape: self.shape)
		view.isFilled = false
		view.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		view.shapeLayer.lineWidth = self.width
		view.shapeLayer.fillColor = nil
		return view
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let view = internalView as? ShapeSwiftUIView<ShapeGeneric> else { return }
		view.isFilled = false
		view.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		view.shapeLayer.lineWidth = self.width
		view.shapeLayer.fillColor = nil
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size
    }
}

public struct FilledView<ShapeGeneric: Shape>: View {
	let shape: ShapeGeneric
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let view = ShapeSwiftUIView(shape: self.shape)
		view.isFilled = true
		view.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		view.shapeLayer.strokeColor = nil
		return view
	}
	
	public func _redraw(view internalView: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let view = internalView as? ShapeSwiftUIView<ShapeGeneric> else { return }
		view.isFilled = true
		view.tintColor = environment.foregroundColor ?? environment.defaultForegroundColor
		view.shapeLayer.strokeColor = nil
	}
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        size
    }
}

internal class ShapeSwiftUIView<ShapeGeneric: Shape>: SwiftUIView {
	var isFilled: Bool = false
	var givenIntrinsicContentSize: CGSize? = nil {
		didSet {
			invalidateIntrinsicContentSize()
		}
	}
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.isFilled {
            return super.point(inside: point, with: event)
        } else {
            return false
        }
    }
	
	override var intrinsicContentSize: CGSize {
		givenIntrinsicContentSize ?? UIView.layoutFittingExpandedSize
	}
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return self.givenIntrinsicContentSize == nil || self.givenIntrinsicContentSize == UIView.layoutFittingExpandedSize
	}
	
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
		if #available(iOS 13.0, *) {
			layer.strokeColor = UIColor.systemBackground.cgColor
		} else {
			layer.strokeColor = UIColor.black.cgColor
		}
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

struct CheckMark: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        }
    }
}
