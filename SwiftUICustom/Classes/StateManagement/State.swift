//
//  State.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

@propertyWrapper
public struct State<T>: DynamicProperty {
	var underlyingValue: T
    var location: Location<T>?
	
	public init(wrappedValue: T) {
		self.underlyingValue = wrappedValue
	}
	
	public var wrappedValue: T {
		get {
            location?.value ?? underlyingValue
		}
        nonmutating set {
            location?.value = newValue
		}
	}
	
	public var projectedValue: Binding<T> {
        return Binding(get: {
            self.wrappedValue
        }, set: {
            self.wrappedValue = $0
        })
	}
    
    public mutating func update(with node: DOMNode, index: Int) {
        self.location = Location(index: index, node: node)
        if node.uiView == nil {
            if node.values.count <= index {
                node.values.append(underlyingValue)
            } else {
                node.values[index] = underlyingValue
            }
        }
    }
}

public extension State where T : ExpressibleByNilLiteral {
    init() {
        self = State(wrappedValue: nil)
    }
}
