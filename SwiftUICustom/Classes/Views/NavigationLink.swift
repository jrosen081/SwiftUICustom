//
//  NavigationLink.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

public struct NavigationLink<Content: View, Destination: View>: View {
    @State private var internalIsActive = false
    @Environment(\.self) var environment
	let destination: Destination
	let content: Content
    let isActive: Binding<Bool>?
    
    private var isActiveWrapper: Bool {
        get {
            self.isActive?.wrappedValue ?? internalIsActive
        }
        nonmutating set {
            if let active = self.isActive {
                active.wrappedValue = newValue
            } else {
                internalIsActive = newValue
            }
        }
       
    }
    
    public init(destination: Destination, isActive: Binding<Bool>? = nil, content:  () -> Content) {
		self.destination = destination
		self.content = content()
        self.isActive = isActive
	}
    
    public init<V: Equatable>(tag: V, selection: Binding<V?>, destination: () -> Destination, content:  () -> Content) {
        let isActive = Binding<Bool> {
            tag == selection.wrappedValue
        } set: { value in
            if value {
                selection.wrappedValue = tag
            } else {
                selection.wrappedValue = nil
            }
        }
        self = NavigationLink(destination: destination(), isActive: isActive, content: content)
    }
	
	public var body: OnChangeView<Bool, OnAppearView<Button<Content>>> {
        Button(action: pushViewController) {
            self.content
        }
        .onAppear(updateViewForState)
        .onChange(of: self.isActiveWrapper) { active in
            updateViewForState()
        }
	}
    
    private func pushViewController() {
        guard let controller = environment.currentStateNode.viewController else { return }
        let internalController = SwiftUIInternalController(swiftUIView: self.destination, environment: environment, domNode: getNewControllerDOMNode())
        internalController.onDeallocate = {
            self.isActiveWrapper = false
        }
        controller.navigationController?.pushViewController(internalController, animated: true)
        if !self.isActiveWrapper {
            self.isActiveWrapper = true
        }
    }
    
    private func updateViewForState() {
        environment.cell?.accessoryType = .disclosureIndicator
        environment.cell?.onClick = pushViewController
        if isActiveWrapper, getNewControllerDOMNode().viewController == nil {
            pushViewController()
        } else if !isActiveWrapper,
                  let controller = getNewControllerDOMNode().viewController,
                  let index = controller.navigationController?.index(of: controller),
                  let allControllers = controller.navigationController?.viewControllers {
            controller.navigationController?.popToViewController(allControllers[max(0, index - 1)], animated: true)
        }
    }
    
    
    private func getNewControllerDOMNode() -> DOMNode {
        if environment.currentStateNode.values.count == 2 {
            let contentDOMNode = DOMNode(environment: environment, viewController: nil, buildingBlock: self.destination)
            environment.currentStateNode.values.append(contentDOMNode)
            return contentDOMNode
        } else {
            return environment.currentStateNode.values[2] as! DOMNode
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
