//
//  NavigationView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationView<Body: View>: View {
	let viewBuilder: Body
	
	public init(_ viewBuilder: () -> Body) {
		self.viewBuilder = viewBuilder()
	}
	
	public var body: Body {
		return viewBuilder
	}
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		let controller = InternalNavigationController(nibName: nil, bundle: nil)
        controller.navigationBar.prefersLargeTitles = true
        enclosingController.addChild(controller)
        environment.currentStateNode.buildingBlock = self.viewBuilder
        let internalController = SwiftUIInternalController(swiftUIView: self.viewBuilder, environment: environment, domNode: environment.currentStateNode)
        environment.currentStateNode.viewController = internalController
        controller.viewControllers = [internalController]
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.insetsLayoutMarginsFromSafeArea = false
        environment.currentStateNode.uiView = controller.view.subviews[0]
        return controller.view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        guard let navigationController = controller.children.first as? UINavigationController else { return }
        guard let actualController = navigationController.viewControllers.first as? SwiftUIInternalController<Body> else { return }
        actualController.swiftUIView = self.viewBuilder
        var newEnvironment = environment
        newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
        actualController.environment = environment
        self.viewBuilder._redraw(view: actualController.view.subviews[0], controller: actualController, environment: environment)
	}
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

class InternalNavigationController: UINavigationController {
}
