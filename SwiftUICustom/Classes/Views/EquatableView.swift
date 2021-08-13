//
//  EquatableView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 6/27/21.
//

import Foundation

public struct EquatableView<Content: View & Equatable>: View {
    let content: Content
    public var body: Content {
        return self.content
    }
    
    public func _isEqual(to other: _BuildingBlock) -> Bool {
        guard let other = other as? Self else { return false }
        return other.content == self.content
    }
}

public extension View where Self: Equatable {
    func equatable() -> EquatableView<Self> {
        return EquatableView(content: self)
    }
}
