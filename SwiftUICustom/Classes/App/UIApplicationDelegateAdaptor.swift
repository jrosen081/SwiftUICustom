//
//  UIApplicationDelegateAdaptor.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/21/21.
//

import Foundation

@propertyWrapper
public struct UIApplicationDelegateAdaptor<DelegateType>: DynamicProperty where DelegateType : NSObject, DelegateType : UIApplicationDelegate {
    
    let delegateType: DelegateType.Type
    
    private var delegate: DelegateType?
    
    public init(_ delegateType: DelegateType.Type = DelegateType.self) {
        self.delegateType = delegateType
    }
    
    public var wrappedValue: DelegateType {
        return delegate ?? DelegateType()
    }
    
    public mutating func update(with node: DOMNode, index: Int) {
        if node.values.count <= index {
            node.update(value: wrappedValue, index: index)
        }
        
        self.delegate = node.get(valueAtIndex: index) as? DelegateType
        (UIApplication.shared.delegate as? DelegateInserter)?.delegate = wrappedValue
    }
}

public extension UIApplicationDelegateAdaptor where DelegateType: ObservableObject {
    var projectedValue: ObservedObject<DelegateType>.Wrapper {
        ObservedObject(wrappedValue: self.wrappedValue).projectedValue
    }
}
