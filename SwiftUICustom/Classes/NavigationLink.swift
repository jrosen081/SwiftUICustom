//
//  NavigationLink.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationLink<Content: View, Destination: View>: View {
	let destination: Destination
	let content: () -> Content
	
	public init(destination: Destination, content: @escaping () -> Content) {
		self.destination = destination
		self.content = content
	}
	
	public var body: Self {
		return self
	}
	
	public func toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue
		let buttonControl = NavigationButtonLink(view: self.content().toUIView(enclosingController: enclosingController, environment: newEnvironment), environment: newEnvironment) {
			enclosingController.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: newEnvironment), animated: true)
		}
		return buttonControl
	}
	
	public func redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
		self.content().redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
	}
}

class NavigationButtonLink: ButtonView {
	let environment: EnvironmentValues
	
	init(view: UIView, environment: EnvironmentValues, onClick: @escaping () -> ()) {
		self.environment = environment
		super.init(view: view, onClick: onClick)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func insideList() -> (() -> ())? {
		guard !self.inList else { return self.onClick }
		self.inList = true
		setupView(HStack {
			UIViewWrapper(view: self.view)
			Spacer()
			Text("->")
		}.padding().toUIView(enclosingController: UIViewController(), environment: self.environment))
		self.isUserInteractionEnabled = false
		return self.onClick
	}
}
