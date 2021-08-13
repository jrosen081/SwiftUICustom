//
//  StateObject.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/28/21.
//

import Foundation

@propertyWrapper
public struct StateObject<Object: ObservableObject>: DynamicProperty {
    @dynamicMemberLookup
    public struct Wrapper {
        let object: Object
        
        public subscript<T>(dynamicMember path: ReferenceWritableKeyPath<Object, T>) -> Binding<T> {
            return Binding(get: { object[keyPath: path] }, set: {
                object[keyPath: path] = $0
            })
        }
    }
    
    internal enum Storage {
        case uninitialized(() -> Object)
        case stored(Object)
        
        var value: Object {
            switch self {
            case .uninitialized(let initializer): return initializer()
            case .stored(let value): return value
            }
        }
    }
    
    var storage: Storage
    
    public init(wrappedValue thunk: @autoclosure @escaping () -> Object) {
        self.storage = .uninitialized(thunk)
    }
    
    public var wrappedValue: Object {
        return storage.value
    }
    
    public var projectedValue: Wrapper {
        return Wrapper(object: wrappedValue)
    }
    
    public mutating func update(with node: DOMNode, index: Int) {
        let value: Object
        if node.values.count <= index {
            value = storage.value
            node.values.append(value)
        } else {
            value = node.values[index] as! Object
        }
        self.storage = .stored(value)
        value.publisher.listenForChanges(identifier: ObjectIdentifier(node)) { [weak node] in
            node?.update(value: value, index: index)
        }
    }
    
}
