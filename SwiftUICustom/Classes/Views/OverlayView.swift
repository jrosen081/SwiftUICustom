//
//  OverlayView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/23/20.
//

import Foundation

public struct OverlayView<Under: View, Over: View>: View {
    let under: Under
    let over: Over
    let alignment: Alignment
    
    public var body: ZStack<TupleView<(Under, Over)>> {
        ZStack(alignment: alignment) {
            self.under
            self.over
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
    
}

public extension View {
    func overlay<V: View>(_ over: V, alignment: Alignment = .center) -> OverlayView<Self, V> {
        return OverlayView(under: self, over: over, alignment: alignment)
    }
}
