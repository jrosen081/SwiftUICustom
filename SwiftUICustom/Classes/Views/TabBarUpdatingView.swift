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
        let underlyingUIView = underlyingView._toUIView(enclosingController: enclosingController, environment: environment)
        let allOptions = tabBarItem.expanded()
        if let image = allOptions.first(where: { $0 is Image }) as? Image {
            enclosingController.tabBarItem.image = image.image
        }
        if let text = allOptions.first(where: { $0 is Text }) as? Text {
            enclosingController.tabBarItem.title = text.text
        }
        enclosingController.tabBarItem.image?.draw(in: CGRect(x: 0, y: 0, width: 30, height: 30))
        return underlyingUIView
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        underlyingView._redraw(view: view, controller: controller, environment: environment)
        let allOptions = tabBarItem.expanded()
        if let image = allOptions.first(where: { $0 is Image }) as? Image {
            controller.tabBarItem.image = image.image
        }
        if let text = allOptions.first(where: { $0 is Text }) as? Text {
            controller.tabBarItem.title = text.text
        }
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        underlyingView._requestedSize(within: size, environment: environment)
    }
}

public extension View {
    func tabBarItem<Type: View>(@ViewBuilder builder: () -> Type) -> TabBarUpdatingView<Self, Type> {
        return TabBarUpdatingView(underlyingView: self, tabBarItem: builder())
    }
}
