//
//  EnvironmentObject.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation

@propertyWrapper
public struct EnvironmentObject<Value: ObservableObject>: DynamicProperty {
    public mutating func update(with node: DOMNode, index: Int) {
        if node.values.count <= index {
            node.values.append(0)
        }
        self.environment = node.environment
        environment[EnvironmentObjectGetter<Value>.self].publisher.listenForChanges(identifier: ObjectIdentifier(node)) {
            node.update(value: 0, index: index)
        }
    }
    
    var environment = EnvironmentValues()
    
    public init() {}
	
	public var wrappedValue: Value {
        return environment[EnvironmentObjectGetter<Value>.self]
	}
}
