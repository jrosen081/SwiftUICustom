//
//  TaggedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/29/20.
//

import Foundation

public struct TaggedView<Tag: Hashable, Content: View>: View, Taggable {
    let tag: Tag
    
    public func _isEqual(toSameType other: TaggedView<Tag, Content>, environment: EnvironmentValues) -> Bool {
        tag == other.tag && content._isEqual(to: other.content, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        tag.hash(into: &hasher)
        content._hash(into: &hasher, environment: environment)
    }
        
    var taggedValue: Any {
        return tag
    }
    
    let content: Content
    public var body: Content {
        content
    }
}

protocol Taggable {
    var taggedValue: Any { get }
}

public extension View {
    func tag<T: Hashable>(_ tag: T) -> TaggedView<T, Self> {
        return TaggedView(tag: tag, content: self)
    }
}
