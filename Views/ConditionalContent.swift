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
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let conditionalContainer = ConditionalContainer(frame: .zero)
		conditionalContainer.translatesAutoresizingMaskIntoConstraints = false
		let underlyingView: UIView
		switch self.actualContent {
		case .first(let view):
			underlyingView = view.toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = true
		case .second(let view): underlyingView = view.toUIView(enclosingController: enclosingController, environment: environment)
			conditionalContainer.isTrue = false
		}
		conditionalContainer.addSubview(underlyingView)
		conditionalContainer.setupFullConstraints(conditionalContainer, underlyingView)
		return conditionalContainer
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		guard let conditional = view as? ConditionalContainer else { return }
		
		switch (self.actualContent, conditional.isTrue) {
		case (.first(let first), true):
			first.redraw(view: conditional.subviews[0], controller: controller, environment: environment)
		case (.first(let first), false):
			conditional.isTrue = true
			conditional.subviews[0].removeFromSuperview()
			let newValue = first.toUIView(enclosingController: controller, environment: environment)
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue)
		case(.second(let second), true):
			conditional.isTrue = false
			conditional.subviews[0].removeFromSuperview()
			let newValue = second.toUIView(enclosingController: controller, environment: environment)
			conditional.addSubview(newValue)
			conditional.setupFullConstraints(conditional, newValue)
		case (.second(let second), false):
			second.redraw(view: conditional.subviews[0], controller: controller, environment: environment)
		}
	}
}

class ConditionalContainer: SwiftUIView {
	var isTrue: Bool = false
}
