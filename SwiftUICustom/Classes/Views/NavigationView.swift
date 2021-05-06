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
        controller.viewControllers = [SwiftUIInternalController(swiftUIView: self.viewBuilder, environment: environment)]
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.insetsLayoutMarginsFromSafeArea = false
        return controller.view
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        guard let navigationController = controller.children.first as? UINavigationController else { return }
        guard let actualController = navigationController.viewControllers.first as? SwiftUIInternalController<Body> else { return }
        actualController.swiftUIView = self.viewBuilder
        actualController.environment = environment
        self.viewBuilder._redraw(view: actualController.view.subviews[0], controller: actualController, environment: environment)
	}
}

class InternalNavigationController: UINavigationController {
}

class NavigationInternalView: UIView {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
