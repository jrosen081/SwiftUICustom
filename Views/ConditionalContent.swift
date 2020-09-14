//
//  ConditionalContent.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation



public struct ConditionalContent<TrueContent: View, FalseContent: View>: View {
	enum ActualContent {
		case first(TrueContent)
		case second(FalseContent)
	}
	
	let actualContent: ActualContent
	
	public var body: Self {
		return self
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let conditionalContainer = ConditionalContainer(frame: .zero)
		conditionalContainer.translatesAutoresizingMaskIntoConstraints = false
		let underlyingView: UIView
		switch self.actualContent {
		case .first(let view):
			underlyingView = view._toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = true
		case .second(let view): underlyingView = view._toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = false
		}
		conditionalContainer.addSubview(underlyingView)
		conditionalContainer.setupFullConstraints(conditionalContainer, underlyingView)
		return conditionalContainer
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let conditional = view as? ConditionalContainer else { return }
		
		let animations: () -> ()
		
		switch (self.actualContent, conditional.isTrue) {
		case (.first(let first), true):
			first._redraw(view: conditional.subviews[0], controller: controller, environment: environment)
			animations = {}
		case (.first(let first), false):
			conditional.isTrue = true
			let newValue = first._toUIView(enclosingController: controller, environment: environment)
			animations = {
				conditional.subviews[0].removeFromSuperview()
				conditional.addSubview(newValue)
				conditional.setupFullConstraints(conditional, newValue)
			}
		case(.second(let second), true):
			conditional.isTrue = false
			let newValue = second._toUIView(enclosingController: controller, environment: environment)
			animations = {
				conditional.subviews[0].removeFromSuperview()
				conditional.addSubview(newValue)
				conditional.setupFullConstraints(conditional, newValue)
			}
		case (.second(let second), false):
			second._redraw(view: conditional.subviews[0], controller: controller, environment: environment)
			animations = {}
		}
		
		if let animation = environment.currentAnimation {
			UIView.animate(withDuration: animation.duration, delay: animation.delay, options: animation.animationOptions, animations: animations)
		} else {
			animations()
		}
	}
}

class ConditionalContainer: SwiftUIView {
	var isTrue: Bool = false
	
	override var intrinsicContentSize: CGSize {
		return self.subviews[0].intrinsicContentSize
	}
}
