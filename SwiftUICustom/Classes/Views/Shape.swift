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
    
    func _isEqual(toSameType other: Self, environment: EnvironmentValues) -> Bool {
        return self.path(in: CGRect(origin: .zero, size: CGSize(width: 100, height: 100))) == other.path(in: CGRect(origin: .zero, size: CGSize(width: 100, height: 100))) // Prob won't work for all cases??
    }
    
    func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        self.path(in: CGRect(origin: .zero, size: CGSize(width: 100, height: 100))).hash(into: &hasher)
    }
	
	func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
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
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
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
    
    public func _isEqual(toSameType other: StrokedView<ShapeGeneric>, environment: EnvironmentValues) -> Bool {
        return shape._isEqual(toSameType: other.shape, environment: environment) && other.width == self.width
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        shape._hash(into: &hasher, environment: environment)
        width.hash(into: &hasher)
    }
}

public struct FilledView<ShapeGeneric: Shape>: View {
	let shape: ShapeGeneric
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
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
    
    public func _isEqual(toSameType other: Self, environment: EnvironmentValues) -> Bool {
        return shape._isEqual(toSameType: other.shape, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        shape._hash(into: &hasher, environment: environment)
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
