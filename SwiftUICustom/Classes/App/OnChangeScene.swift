//
//  OnChangeScene.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/28/21.
//

import Foundation

@available(iOS 13.0, *)
struct OnChangeScene<S: Scene, Value: Equatable>: Scene {
    let s: S
    let value: Value
    let callback: (Value) -> ()
    
    public var body: S { s }
    
    public static func _startScene(delegate: UIWindowSceneDelegate, self: OnChangeScene<S, Value>, domNode: DOMNode) -> UIViewController {
        let currentValue = _StateNode(view: self, node: domNode)
        let body = currentValue.s
        let newNode = domNode.childNodes.first ?? self.makeNode(parentNode: domNode, body: body, delegate: delegate)
        newNode.environment = domNode.environment
        domNode.values.append(self.value)
        let controller = type(of: body)._startScene(delegate: delegate, self: body, domNode: newNode)
        newNode.viewController = controller
        domNode.viewController = controller
        return controller
    }
    
    public static func _updateScene(delegate: UIWindowSceneDelegate, self: OnChangeScene<S, Value>, domNode: DOMNode, controller: UIViewController) {
        let currentValue = _StateNode(view: self, node: domNode)
        let body = currentValue.s
        let node = domNode.childNodes[0]
        node.environment = domNode.environment
        type(of: body)._updateScene(delegate: delegate, self: body, domNode: node, controller: controller)
        if domNode.get(valueAtIndex: 0) as! Value != self.value {
            DispatchQueue.main.async {
                self.callback(self.value)
            }
        }
        domNode.values[0] = self.value
    }
}

@available(iOS 13.0, *)
public extension Scene {
    func onChange<V: Equatable>(of value: V, perform: @escaping (V) -> Void) -> some Scene {
        OnChangeScene(s: self, value: value, callback: perform)
    }
}
