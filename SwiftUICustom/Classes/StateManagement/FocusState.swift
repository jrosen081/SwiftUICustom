//
//  FocusState.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/25/21.
//

import Foundation

@propertyWrapper
public struct FocusState<Value>: DynamicProperty {
    @State private var value: Value
    let defaultValue: Value
    
    public init() where Value == Bool {
        self._value = State(initialValue: false)
        self.defaultValue = false
    }
    
    public init<T>() where T? == Value {
        self._value = State(initialValue: nil)
        self.defaultValue = nil
    }

    public var wrappedValue: Value {
        get {
            value
        }
        
        nonmutating set {
            value = newValue
        }
    }
    
    public var projectedValue: Binding {
        Binding(binding: $value, defaultValue: defaultValue)
    }
    
    public struct Binding {
        let binding: SwiftUICustom.Binding<Value>
        let defaultValue: Value
        
        public var wrappedValue: Value {
            get {
                return binding.wrappedValue
            }
            nonmutating set {
                binding.wrappedValue = newValue
            }
        }
        
        func reset() {
            self.binding.wrappedValue = defaultValue
        }
    }
    
    public mutating func update(with node: DOMNode, index: Int) {
        self._value.update(with: node, index: index)
    }
}

struct IsForcedFocusedKey: EnvironmentKey {
    static var defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var isForcedFocus: Bool? {
        get {
            self[IsForcedFocusedKey.self]
        }
        set {
            self[IsForcedFocusedKey.self] = newValue
        }
    }
}

struct OnFocusChangeKey: EnvironmentKey {
    static var defaultValue: (Bool) -> Void = {_ in }
}

extension EnvironmentValues {
    var onFocusChange: (Bool) -> Void {
        get {
            self[OnFocusChangeKey.self]
        }
        set {
            let currentChange = self[OnFocusChangeKey.self]
            self[OnFocusChangeKey.self] = { change in
                newValue(change)
                currentChange(change)
            }
        }
    }
}

public extension View {
    func focused<Value>(_ binding: FocusState<Value>.Binding, equals value: Value) -> EnvironmentUpdatingView<EnvironmentUpdatingView<Self>> where Value : Hashable {
        self
            .environment(\.isForcedFocus, binding.wrappedValue == value)
            .environment(\.onFocusChange) { isFocused in
                if isFocused {
                    binding.wrappedValue = value
                } else {
                    binding.reset()
                }
            }
    }
    
    func focused(_ binding: FocusState<Bool>.Binding) -> EnvironmentUpdatingView<EnvironmentUpdatingView<Self>> {
        focused(binding, equals: true)
    }
}
