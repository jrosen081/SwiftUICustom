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
	
	public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
		var newEnvironment = environment
        weak var controller: UIViewController? = enclosingController
        let contentDOMNode = DOMNode(environment: environment, viewController: enclosingController, buildingBlock: self.content)
        newEnvironment.currentStateNode = contentDOMNode
        environment.currentStateNode.addChild(node: contentDOMNode, index: 0)
        let newDomNode = DOMNode(environment: environment, viewController: nil, buildingBlock: self.destination)
        environment.currentStateNode.addChild(node: newDomNode, index: 1)
        let contentView = self.content._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        environment.currentStateNode.uiView = contentView
        let pushViewController = {
            let internalController = SwiftUIInternalController(swiftUIView: self.destination, environment: environment, domNode: newDomNode)
            newDomNode.viewController = internalController
            controller?.navigationController?.pushViewController(internalController, animated: true)
        }
        
        environment.currentStateNode.buildingBlock = self.content
        if let cell = environment.cell {
            cell.accessoryType = .disclosureIndicator
            cell.onClick = pushViewController
        } else {
            newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue
        }
        let cell = NavigationButtonLink(view: contentView, environment: newEnvironment, onClick: pushViewController)
        cell.isUserInteractionEnabled = environment.cell == nil
        return cell
	}
	
	public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        weak var usableController: UIViewController? = controller
		var newEnvironment = environment
        newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
        if let cell = environment.cell {
            cell.accessoryType = .disclosureIndicator
        } else {
            newEnvironment.foregroundColor = newEnvironment.foregroundColor ?? .systemBlue

        }
        self.content._redraw(view: view.subviews[0], controller: controller, environment: newEnvironment)
		guard let navigationButton = view as? NavigationButtonLink else { return }
        navigationButton.onClick = {
            let internalController = SwiftUIInternalController(swiftUIView: self.destination, environment: environment, domNode: environment.currentStateNode.childNodes[1])
            usableController?.navigationController?.pushViewController(internalController, animated: true)
        }
        
        environment.cell?.onClick = navigationButton.onClick
        
        if let navController = controller.navigationController,
           let index = navController.index(of: controller),
           navController.viewControllers.count > index + 1,
           let controller = navController.viewControllers[index + 1] as? SwiftUIInternalController<Destination> {
            var newEnvironment = environment
            newEnvironment.currentStateNode = controller.domNode
            self.destination._redraw(view: controller.view.subviews[0], controller: controller, environment: newEnvironment)
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
}

private extension UINavigationController {
    func index(of controller: UIViewController) -> Int? {
        for (offset, enumeratedController) in self.viewControllers.enumerated() {
            if enumeratedController == controller {
                return offset
            } else if enumeratedController.children.contains(controller: controller) {
                return offset
            }
        }
        return nil
    }
}

private extension Array where Element == UIViewController {
    func contains(controller usableController: Element) -> Bool {
        return self.contains(where: { controller in controller == usableController || controller.children.contains(controller: usableController) })
    }
}
