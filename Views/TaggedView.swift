//
//  TaggedView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/29/20.
//

import Foundation

public struct TaggedView<Tag: Equatable, Content: View>: View {
    let tag: Tag
    let content: Content
    public var body: Content {
        content
    }
}

public extension View {
    func tag<T: Equatable>(_ tag: T) -> TaggedView<T, Self> {
        return TaggedView(tag: tag, content: self)
    }
}
