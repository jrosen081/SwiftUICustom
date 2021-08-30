//
//  UIViewUpdatingView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public struct UIViewWrappingView<Content: View>: View {
    let content: Content
    let updater: (SwiftUIView) -> Void
    var addConstraints: (UIView, UIView) -> Void = { $0.setupFullConstraints($0, $1) }
    public var body: Self {
        return self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let view = SwiftUIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        environment.currentStateNode.buildingBlock = content
        let underlyingView = content._toUIView(enclosingController: enclosingController, environment: environment)
        environment.currentStateNode.uiView = underlyingView
        view.addSubview(underlyingView)
        updater(view)
        addConstraints(view, underlyingView)
        return view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        guard let view = view as? SwiftUIView else { return }
        view.constraints.forEach { $0.isActive = false }
        content._redraw(view: view.subviews[0], controller: controller, environment: environment)
        updater(view)
        addConstraints(view, view.subviews[0])
    }
}
