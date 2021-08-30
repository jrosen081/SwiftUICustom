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
        var newEnvironment = environment
		switch self.actualContent {
		case .first(let view):
            let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: view)
            newEnvironment.currentStateNode = newNode
			underlyingView = view._toUIView(enclosingController: enclosingController, environment: newEnvironment)
            newNode.uiView = underlyingView
            environment.currentStateNode.addChild(node: newNode, index: 0)
			conditionalContainer.isTrue = true
		case .second(let view):
            let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: view)
            newEnvironment.currentStateNode = newNode
            underlyingView = view._toUIView(enclosingController: enclosingController, environment: newEnvironment)
            newNode.uiView = underlyingView
            environment.currentStateNode.addChild(node: newNode, index: 0)
			conditionalContainer.isTrue = false
		}
		conditionalContainer.addSubview(underlyingView)
		conditionalContainer.setupFullConstraints(conditionalContainer, underlyingView, usingGreaterThan: false)
		return conditionalContainer
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let conditional = view as? ConditionalContainer else { return }
		
		let whenFinished: () -> ()
		let transitions: (AnyTransition) -> ()
        var newEnvironment = environment
		switch (self.actualContent, conditional.isTrue) {
		case (.first(let first), true):
            newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
			first._redraw(view: conditional.subviews[0], controller: controller, environment: newEnvironment)
			return
		case (.first(let first), false):
			conditional.isTrue = true
            let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: controller, buildingBlock: first)
            newEnvironment.currentStateNode = newNode
            var newValue = first._toUIView(enclosingController: controller, environment: newEnvironment)
            environment.currentStateNode.childNodes[0] = newNode
			var applyTransition = true
			if conditional.subviews.count == 2 {
				applyTransition = false
				newValue = conditional.subviews[0]
				first._redraw(view: newValue, controller: controller, environment: environment)
			}
            newNode.uiView = newValue
			whenFinished = {
				conditional.subviews.filter { $0 != newValue }.forEach { $0.removeFromSuperview() }
                conditional.sizeToFit()
			}
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue, usingGreaterThan: false)
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
            let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: controller, buildingBlock: second)
            newEnvironment.currentStateNode = newNode
            var newValue = second._toUIView(enclosingController: controller, environment: newEnvironment)
            environment.currentStateNode.childNodes[0] = newNode
			var applyTransition = true
			if conditional.subviews.count == 2 {
				applyTransition = false
				newValue = conditional.subviews[0]
				second._redraw(view: newValue, controller: controller, environment: environment)
			}
            newNode.uiView = newValue
			whenFinished = {
				conditional.subviews.filter { $0 != newValue }.forEach { $0.removeFromSuperview() }
                conditional.sizeToFit()
			}
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue, usingGreaterThan: false)
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
            newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
			second._redraw(view: conditional.subviews[0], controller: controller, environment: newEnvironment)
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
