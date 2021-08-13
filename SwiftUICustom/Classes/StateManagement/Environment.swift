//
//  Environment.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/20.
//

import Foundation

@propertyWrapper
public struct Environment<Value>: DynamicProperty {
	var environment: EnvironmentValues = EnvironmentValues()
	let environmentFunc: (EnvironmentValues) -> Value
	
	public init(_ environmentFunc: @escaping (EnvironmentValues) -> Value) {
		self.environmentFunc = environmentFunc
	}
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self = Environment { $0[keyPath: keyPath] }
    }
	
	public var wrappedValue: Value {
		return environmentFunc(environment)
	}
    
    public mutating func update(with node: DOMNode, index: Int) {
        self.environment = node.environment
        if node.values.count <= index {
            node.values.append(0)
        }
    }
}
