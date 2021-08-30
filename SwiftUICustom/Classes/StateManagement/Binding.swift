//
//  Binding.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/29/20.
//

import Foundation

@propertyWrapper
@dynamicMemberLookup
public struct Binding<T>: DynamicProperty {
	var get: () -> T
	var set: (T) -> ()
	
	public init(get: @escaping () -> T, set: @escaping (T) -> ()) {
		self.get = get
		self.set = set
	}
    
    static func constant(_ value: T) -> Binding<T> {
        return Binding(get: {
            value
        }, set: {_ in })
    }
    
    public func animation(_ animation: Animation) -> Binding<T> {
        Binding(get: get, set: { newValue in
            withAnimation(animation: animation) {
                set(newValue)
            }
        })
    }
	
	public var wrappedValue: T {
		get {
			self.get()
		}
		nonmutating set {
			self.set(newValue)
		}
	}
	
	public var projectedValue: Binding<T> {
		return self
	}
    
    public func update(with node: DOMNode, index: Int) { // Do nothing but take up space here
        if node.values.count <= index {
            node.values.append(0)
        }
    }
    
    public subscript<K>(dynamicMember key: WritableKeyPath<T, K>) -> Binding<K> {
        Binding<K>(get: {
            self.wrappedValue[keyPath: key]
        }, set: {
            self.wrappedValue[keyPath: key] = $0
        })
    }
}
