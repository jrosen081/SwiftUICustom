//
//  Button.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/28/20.
//

import Foundation

public struct Button<ButtonContent: View>: View {
	let content: () -> ButtonContent
	let onClick: () -> ()
	
	public init(content: @escaping () -> ButtonContent, onClick: @escaping () -> ()) {
		self.content = content
		self.onClick = onClick
	}
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
		let view = self.content()._toUIView(enclosingController: enclosingController, environment: newEnvironment)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		return ButtonView(view: view, onClick: self.onClick)
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
		self.content()._redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
	}
	
}

class ButtonView: SwiftUIView {
	var view: UIView
	let onClick: () -> ()
	var inList: Bool = false
	
	override func willExpand(in context: ExpandingContext) -> Bool {
		return view.willExpand(in: context)
	}
	
	init(view: UIView, onClick: @escaping () -> ()) {
		self.view = view
		self.onClick = onClick
		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = false
		setupView(view)
	}
	
	func setupView(_ view: UIView) {
		self.subviews.forEach {
			$0.constraints.forEach({ $0.isActive = false })
			$0.removeFromSuperview()
		}
		view.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(view)
		self.view = view
		self.setupFullConstraints(self.view, self)

	}
	
	override func insideList(width: CGFloat) -> (() -> ())? {
		self.isUserInteractionEnabled = false
		self.inList = true
		return self.onClick
	}
	
	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		self.view.alpha = 0.3
		return super.beginTracking(touch, with: event)
	}
	
	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		if !self.point(inside: touch.location(in: self), with: event) {
			self.cancelTracking(with: event)
			return false
		}
		return true
	}
	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		self.view.alpha = 1
		self.onClick()
	}
	
	override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		self.view.alpha = 1
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func buttonClicked(tap: UITapGestureRecognizer) {
		switch tap.state {
		case .began:
			view.alpha = 0.3
		case .cancelled, .failed:
			view.alpha = 1
		case .ended:
			view.alpha = 1
			self.onClick()
		default:
			break
		}
	}

	static func == (lhs: ButtonView, rhs: ButtonView) -> Bool {
		return lhs.view == rhs.view
	}
}

class TapSelectorHolder {
	let closure: (UITapGestureRecognizer) -> ()
	
	init(closure: @escaping (UITapGestureRecognizer) -> ()) {
		self.closure = closure
	}
	
	@objc func selected(tap: UITapGestureRecognizer) {
		self.closure(tap)
	}
}


