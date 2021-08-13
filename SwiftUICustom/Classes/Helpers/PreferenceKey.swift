//
//  PreferenceKey.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/28/21.
//

import Foundation

public protocol PreferenceKey {
    associatedtype Value
    static var defaultValue: Self.Value { get }
    static func reduce(value: inout Self.Value, nextValue: () -> Self.Value)
}

class PreferenceKeyValue<K: PreferenceKey>: NSObject, ObservableObject {
    @Published var value: K.Value
    var changeCount: Int = 0
    
    init(value: K.Value) {
        self.value = value
    }
    
    func setValue(value: K.Value) {
        K.reduce(value: &self.value, nextValue: { value })
        changeCount += 1
    }
    
    
}

internal struct EnvironmentPreferenceKey<Key: PreferenceKey>: EnvironmentKey {
    typealias Value = PreferenceKeyValue<Key>
    static var defaultValue: PreferenceKeyValue<Key> {
        PreferenceKeyValue(value: Key.defaultValue)
    }
}
