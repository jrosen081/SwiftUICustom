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
        let allOptions = content._makeSequence(currentNode: environment.currentStateNode).expanded(node: environment.currentStateNode)
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = allOptions.enumerated().map { index, view in
            let controller = SwiftUIInternalController.init(swiftUIView: view.0, environment: view.1.environment, domNode: view.1)
            controller.environment = environment
            environment.currentStateNode.addChild(node: controller.domNode, index: index)
            controller.loadViewIfNeeded()
            return controller
        }
        enclosingController.addChild(tabBarController)
        tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        tabBarController.view.insetsLayoutMarginsFromSafeArea = false
        
        return tabBarController.view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allOptions = content._makeSequence(currentNode: environment.currentStateNode).expanded(node: environment.currentStateNode)
        allOptions.forEach { view, node in
            node.buildingBlock = view
            node.environment = environment
            node.redraw(animation: environment.currentAnimation)
        }
    }
}
