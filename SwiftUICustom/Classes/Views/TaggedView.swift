//
//  TaggedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/29/20.
//

import Foundation

public struct TaggedView<Tag: Equatable, Content: View>: View, Taggable {
    let tag: Tag
    
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
    func tag<T: Equatable>(_ tag: T) -> TaggedView<T, Self> {
        return TaggedView(tag: tag, content: self)
    }
}
