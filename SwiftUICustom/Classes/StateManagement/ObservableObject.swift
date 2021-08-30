//
//  ObservableObject.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/7/20.
//

import Foundation
import Runtime

var publishers = [ObjectIdentifier: ObservablePublisher]()

public protocol ObservablePublisher: AnyObject {
    func listenForChanges(identifier: ObjectIdentifier, thunk: @escaping () -> Void)
    func send()
}

public protocol ObservableObject : AnyObject {
    var publisher: ObservablePublisher { get }
}

class Publisher: ObservablePublisher, Updater {
    func update(value: Any, index: Int, shouldRedraw: Bool) {
        self.send()
        self.values[index] = value
    }
    
    func get(valueAtIndex: Int) -> Any {
        return self.values[valueAtIndex]
    }
    
    var thunks: [ObjectIdentifier: () -> Void] = [:]
    var values: [Any] = []
    weak var object: ObservableObject? {
        willSet {
            if newValue == nil, let currentObject = object {
                publishers[ObjectIdentifier(currentObject)] = nil
            }
        }
    }
    func listenForChanges(identifier: ObjectIdentifier, thunk: @escaping () -> Void) {
        self.thunks[identifier] = thunk
    }
    
    func send() {
        self.thunks.values.forEach { $0() }
    }
    
    init<Object: ObservableObject>(object: Object) {
        var object = object
        self.object = object
        let mirror = Mirror(reflecting: object)
        mirror.children.compactMap { (key, value) in
            guard let key = key, let value = value as? Publishable else { return nil }
            return (key, value)
        }.enumerated().forEach { (offset: Int, keyValue: (key: String, value: Publishable)) in
            guard let type = try? typeInfo(of: Object.self) else { return }
            let (key, value) = keyValue
            if self.values.count <= offset {
                self.values.append(value.anyValue)
            }
            var newValue = value
            newValue.addUpdater(updater: self, index: offset)
            try? type.property(named: key).set(value: newValue, on: &object)
        }
    }
}

public extension ObservableObject {
    var publisher: ObservablePublisher {
        let publisher: ObservablePublisher = publishers[ObjectIdentifier(self)] ?? Publisher(object: self)
        publishers[ObjectIdentifier(self)] = publisher
        return publishers[ObjectIdentifier(self)]!
    }
}

protocol Publishable {
    mutating func addUpdater(updater: Updater, index: Int)
    var anyValue: Any { get }
}

@propertyWrapper
public struct Published<Value>: Publishable {
    mutating func addUpdater(updater: Updater, index: Int) {
        self.location = Location(index: index, node: updater)
    }
    var value: Value
    var location: Location<Value>?
    
    var anyValue: Any {
        return value
    }
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
	public var wrappedValue: Value {
		get {
            return location?.value ?? self.value
		}
		nonmutating set {
            location?.value = newValue
		}
	}
}

internal class ObjectHolder: Updater {
    var values: [Any] = []
    let onUpdate: (ObjectHolder) -> Void
    init(onUpdate: @escaping (ObjectHolder) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func update(value: Any, index: Int, shouldRedraw: Bool) {
        self.values[index] = value
        onUpdate(self)
    }
    
    func get(valueAtIndex: Int) -> Any {
        return values[valueAtIndex]
    }
}

@propertyWrapper
public struct ObservedObject<Object: ObservableObject>: DynamicProperty {
    
    @dynamicMemberLookup
    public struct Wrapper {
        let object: Object
        
        public subscript<T>(dynamicMember path: ReferenceWritableKeyPath<Object, T>) -> Binding<T> {
            return Binding(get: { object[keyPath: path] }, set: {
                object[keyPath: path] = $0
            })
        }
    }
    
    public mutating func update(with node: DOMNode, index: Int) {
        let publisher = self.value.publisher
        if node.values.count <= index {
            node.values.append(publisher)
        } else {
            node.values[index] = publisher
        }
        publisher.listenForChanges(identifier: ObjectIdentifier(node)) { [weak publisher] in
            guard let publisher = publisher else { return }
            node.update(value: publisher, index: index, shouldRedraw: true)
        }
    }
    
	var value: Object
	
	public init(wrappedValue: Object) {
		self.value = wrappedValue
	}
	
	public var wrappedValue: Object {
		return value
	}
    
    public var projectedValue: Wrapper {
        Wrapper(object: self.value)
    }
}
