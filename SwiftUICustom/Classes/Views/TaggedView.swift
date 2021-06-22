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
}

protocol Taggable {
    var taggedValue: AnyHashable { get }
}

public extension View {
    func tag<T: Hashable>(_ tag: T) -> TaggedView<T, Self> {
        return TaggedView(tag: tag, content: self)
    }
}
