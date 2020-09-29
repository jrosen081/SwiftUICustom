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
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let conditionalContainer = ConditionalContainer(frame: .zero)
		conditionalContainer.translatesAutoresizingMaskIntoConstraints = false
		let underlyingView: UIView
		switch self.actualContent {
		case .first(let view):
			underlyingView = view.__toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = true
		case .second(let view): underlyingView = view.__toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = false
		}
		conditionalContainer.addSubview(underlyingView)
		conditionalContainer.setupFullConstraints(conditionalContainer, underlyingView, usingGreaterThan: true)
		return conditionalContainer
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let conditional = view as? ConditionalContainer else { return }
		
		let whenFinished: () -> ()
		let transitions: (AnyTransition) -> ()
		
		switch (self.actualContent, conditional.isTrue) {
		case (.first(let first), true):
			first._redraw(view: conditional.subviews[0], controller: controller, environment: environment)
			return
		case (.first(let first), false):
			conditional.isTrue = true
			var newValue = first.__toUIView(enclosingController: controller, environment: environment)
			var applyTransition = true
			if conditional.subviews.count == 2 {
				applyTransition = false
				newValue = conditional.subviews[0]
				first._redraw(view: newValue, controller: controller, environment: environment)
			}
			whenFinished = {
				conditional.subviews.filter { $0 != newValue }.forEach { $0.removeFromSuperview() }
			}
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue, usingGreaterThan: true)
			conditional.bringSubviewToFront(newValue)
			if let transition = environment.currentTransition, environment.currentAnimation != nil, applyTransition {
				transition.performTransition(newValue, controller.view.bounds.size, true)
			}
			transitions = { transition in
				transition.performTransition(conditional.subviews[0], controller.view.bounds.size, false)
				newValue.alpha = 1
				newValue.transform = .identity
			}
		case(.second(let second), true):
			conditional.isTrue = false
			var newValue = second.__toUIView(enclosingController: controller, environment: environment)
			var applyTransition = true
			if conditional.subviews.count == 2 {
				applyTransition = false
				newValue = conditional.subviews[0]
				second._redraw(view: newValue, controller: controller, environment: environment)
			}
			whenFinished = {
				conditional.subviews.filter { $0 != newValue }.forEach { $0.removeFromSuperview() }
			}
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue, usingGreaterThan: true)
			conditional.bringSubviewToFront(newValue)
			if let transition = environment.currentTransition, environment.currentAnimation != nil, applyTransition {
				transition.performTransition(newValue, controller.view.bounds.size, true)
			}
			transitions = { transition in
				transition.performTransition(conditional.subviews[0], controller.view.bounds.size, false)
				newValue.alpha = 1
				newValue.transform = .identity
			}
		case (.second(let second), false):
			second._redraw(view: conditional.subviews[0], controller: controller, environment: environment)
			return
		}
		
		conditional.animator?.stopAnimation(true)
		if let animation = environment.currentAnimation {
			conditional.animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animation.duration, delay: animation.delay, options: animation.animationOptions, animations: {
				if let transition = environment.currentTransition {
					transitions(transition)
				}
			}) { done in
				if done == .end {
					whenFinished()
				}
			}
		} else {
			whenFinished()
		}
	}
}

class ConditionalContainer: SwiftUIView {
	var isTrue: Bool = false
	var animator: UIViewPropertyAnimator? = nil
}
