//
//  NavigationLink.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationLink<Content: View, Destination: View>: View {
	let destination: Destination
	let content: Content
	
	public init(destination: Destination, content:  () -> Content) {
		self.destination = destination
		self.content = content()
	}
	
	public var body: Self {
		return self
	}
	
	public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue
		let buttonControl = NavigationButtonLink(view: self.content.__toUIView(enclosingController: enclosingController, environment: newEnvironment), environment: newEnvironment) {
			enclosingController.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: newEnvironment), animated: true)
		}
		return buttonControl
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
		var newEnvironment = EnvironmentValues(environment)
		newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? UIColor.systemBlue
		self.content._redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
		guard let navigationButton = view as? NavigationButtonLink else { return }
		navigationButton.onClick = {
			controller.navigationController?.pushViewController(SwiftUIInternalController(swiftUIView: self.destination, environment: newEnvironment), animated: true)
		}
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
	
	override func insideList(width: CGFloat) -> (() -> ())? {
		guard !self.inList else { return self.onClick }
		self.inList = true
		let shapeView = RightArrow().stroke(lineWidth: 1).__toUIView(enclosingController: UIViewController(), environment: self.environment) as! ShapeSwiftUIView<RightArrow>
		let fullSize = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		shapeView.givenIntrinsicContentSize = CGSize(width: 10, height: fullSize.height)
		let paddingView = UIViewWrapper(view: shapeView).padding(paddingSpace: 5).__toUIView(enclosingController: UIViewController(), environment: self.environment)
		let stackView = SwiftUIStackView(arrangedSubviews: [self.view, ExpandingView(), paddingView], context: .horizontal)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		setupView(UIViewWrapper(view: stackView).padding().__toUIView(enclosingController: UIViewController(), environment: self.environment))
		self.isUserInteractionEnabled = false
		return self.onClick
	}
}
