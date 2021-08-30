//
//  OnChangeView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/27/21.
//

import Foundation

public struct OnChangeView<V: Equatable, Content: View>: View {
    let value: V
    let content: Content
    let onChange: (V) -> Void
    
    public var body: Self {
        return self
    }
    
    public func _toUIView(enclosingController: UIViewController, environment: EnvironmentValues) -> UIView {
        let newNode = type(of: environment.currentStateNode).makeNode(environment: environment, viewController: enclosingController, buildingBlock: self.content)
        var newEnvironment = environment
        newEnvironment.currentStateNode = newNode
        let view = content._toUIView(enclosingController: enclosingController, environment: newEnvironment)
        newNode.uiView = view
        environment.currentStateNode.addChild(node: newNode, index: 0)
        if environment.currentStateNode.values.isEmpty {
            environment.currentStateNode.values.append(value)
        }
        environment.currentStateNode.values[0] = value
        return view
    }
    
    public func _redraw(view: UIView, controller: UIViewController, environment: EnvironmentValues) {
        var newEnvironment = environment
        newEnvironment.currentStateNode = environment.currentStateNode.childNodes[0]
        self.content._redraw(view: view, controller: controller, environment: newEnvironment)
        let oldValue = environment.currentStateNode.values[0] as! V
        environment.currentStateNode.values[0] = self.value
        if oldValue != self.value {
            onChange(self.value)
        }
    }
}

public extension View {
    func onChange<V: Equatable>(of value: V, perform: @escaping (V) -> Void) -> OnChangeView<V, Self> {
        OnChangeView(value: value, content: self, onChange: perform)
    }
}
