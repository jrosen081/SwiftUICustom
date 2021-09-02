//
//  ShadowView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/6/21.
//

import Foundation

public struct ShadowView<Content: View>: View {
    let content: Content
    let color: UIColor
    let width: CGFloat
    let offset: CGSize
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: content) { view in
            view.layer.shadowColor = color.cgColor
            view.layer.shadowOffset = offset
            view.layer.shadowRadius = width
            view.layer.shadowOpacity = 1
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

public extension View {
    func shadow(color: UIColor = .black, width: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> ShadowView<Self> {
        return ShadowView(content: self, color: color, width: width, offset: CGSize(width: x, height: y ))
    }
}
