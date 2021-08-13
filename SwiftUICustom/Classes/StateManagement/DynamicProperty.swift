//
//  DynamicProperty.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/21/21.
//

import Foundation
import Runtime

public protocol DynamicProperty {
    mutating func update(with node: DOMNode, index: Int)
}

public extension DynamicProperty {
     mutating func update(with node: DOMNode, index: Int) {
        let domNode: DOMNode
        if node.values.count <= index {
            let internalNode = DOMNode(environment: node.environment, viewController: node.viewController, buildingBlock: node.buildingBlock)
            node.values.append(internalNode)
            domNode = internalNode
        } else {
            domNode = node.values[index] as! DOMNode
        }
        let mirror = Mirror(reflecting: self)
        let mappedNodes = mirror.children.compactMap { label, value -> (key: String, value: DynamicProperty)? in
            guard let label = label, let value = value as? DynamicProperty else { return nil }
            return (key: label, value: value)
        }
        guard let info = try? typeInfo(of: Self.self) else { return }
        for (offset, node) in mappedNodes.enumerated() {
            var property = node.value
            property.update(with: domNode, index: offset)
            try? info.property(named: node.key).set(value: property, on: &self)
        }
    }
}
