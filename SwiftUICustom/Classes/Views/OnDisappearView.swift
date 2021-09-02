//
//  OnDisappearView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/15/21.
//

import Foundation

public struct OnDisappearView<V: View>: View {
    let v: V
    let onDisappear: () -> Void
    
    public var body: UIViewWrappingView<V> {
        UIViewWrappingView(content: v) { view in
            view.onDisappear = onDisappear
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

public extension View {
    func onDisappear(perform: @escaping () -> Void) -> OnDisappearView<Self> {
        OnDisappearView(v: self, onDisappear: perform)
    }
}
