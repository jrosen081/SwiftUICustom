//
//  TabView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public struct TabView<Selection: Equatable, Content: View>: View {
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
    
    public func __toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let allOptions = content.expanded()
        let tabBarController = UITabBarController(nibName: nil, bundle: nil)
        tabBarController.viewControllers = allOptions.map(BuildingBlockRepresentable.init(buildingBlock:)).map(SwiftUIController.init(swiftUIView:))
        enclosingController.addChild(tabBarController)
        tabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        tabBarController.view.insetsLayoutMarginsFromSafeArea = false
        return tabBarController.view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        let allOptions = content.expanded()
        guard let tabBarController = controller.children.first(where: { $0 is UITabBarController }) as? UITabBarController else { return }
        zip(tabBarController.viewControllers!, allOptions).forEach {(controller, view) in
            view._redraw(view: controller.view.subviews[0], controller: controller, environment: environment)
        }
    }
}