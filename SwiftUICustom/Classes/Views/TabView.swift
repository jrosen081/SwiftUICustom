//
//  TabView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public struct TabView<Selection: Hashable, Content: View>: View {
    
    let content: Content
    let binding: Binding<Selection>?
    
    public init(@ViewBuilder content: () -> Content) where Selection == Int {
        self = TabView(selection: nil, content: content)
    }
    
    public init(selection: Binding<Selection>?, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.binding = selection
    }
    
    public var body: Self {
        return self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let allOptions = content.expanded()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = allOptions.map(_BuildingBlockRepresentable.init(buildingBlock:)).enumerated().map { index, view in
            let controller = SwiftUIController.init(swiftUIView: view)
            controller.environment = environment
            controller.loadViewIfNeeded()
            environment.currentStateNode.addChild(node: controller.domNode, index: index)
            return controller
        }
        enclosingController.addChild(tabBarController)
        tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        tabBarController.view.insetsLayoutMarginsFromSafeArea = false
        
        return tabBarController.view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allOptions = content.expanded()
        guard let tabBarController = controller.children.first(where: { $0 is UITabBarController }) as? UITabBarController else { return }
        let nodes = environment.currentStateNode.childNodes
        zip(zip(tabBarController.viewControllers!, allOptions), nodes).forEach {(viewControllerOptions, node) in
            let (controller, view) = viewControllerOptions
            var newEnvironment = environment
            newEnvironment.currentStateNode = node
            view._redraw(view: controller.view.subviews[0], controller: controller, environment: newEnvironment)
        }
    }
}
