//
//  TaggedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/29/20.
//

import Foundation

public struct TaggedView<Tag: Hashable, Content: View>: View, Taggable {
    let tag: Tag
        
    var taggedValue: AnyHashable {
        return AnyHashable(tag)
    }
    
    let content: Content
    public var body: Content {
        content
    }
    
    public func _isEqual(to other: _BuildingBlock) -> Bool {
        guard let other = other as? Self else { return false }
        return other.tag == self.tag
    }
    
    public func _hash(into hasher: inout Hasher) {
        tag.hash(into: &hasher)
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

protocol Taggable {
    var taggedValue: AnyHashable { get }
}

public extension View {
    func tag<T: Hashable>(_ tag: T) -> TaggedView<T, Self> {
        return TaggedView(tag: tag, content: self)
    }
}
