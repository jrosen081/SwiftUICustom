//
//  TabBarUpdatingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/8/20.
//

import Foundation

public struct TabBarUpdatingView<Content: View, TabBarItem: View>: View {
    let underlyingView: Content
    let tabBarItem: TabBarItem
    
    public var body: Self {
        return self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        environment.currentStateNode.buildingBlock = underlyingView
        let underlyingUIView = underlyingView._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = underlyingUIView
        let allOptions = tabBarItem._makeSequence(currentNode: environment.currentStateNode).expanded(node: environment.currentStateNode).map(\.0)
        if let image = allOptions.compactMap(\.image).first {
            enclosingController.tabBarItem.image = image
        }
        if let text = allOptions.compactMap(\.text).first {
            enclosingController.tabBarItem.title = text
        }
        enclosingController.tabBarItem.image?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        return underlyingUIView
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        underlyingView._redraw(view: view, controller: controller, environment: environment)
        let allOptions = tabBarItem._makeSequence(currentNode: environment.currentStateNode).expanded(node: environment.currentStateNode).map(\.0)
        if let image = allOptions.compactMap(\.image).first {
            controller.tabBarItem.image = image
        }
        if let text = allOptions.compactMap(\.text).first {
            controller.tabBarItem.title = text
        }
    }
}

public extension View {
    func tabBarItem<Type: View>(@ViewBuilder builder: () -> Type) -> TabBarUpdatingView<Self, Type> {
        return TabBarUpdatingView(underlyingView: self, tabBarItem: builder())
    }
}
