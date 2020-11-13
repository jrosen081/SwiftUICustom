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
    
}

class OverlayUIKitView: SwiftUIView {
    override var intrinsicContentSize: CGSize {
        return self.subviews[0].intrinsicContentSize
    }
    
    override func willExpand(in context: ExpandingContext) -> Bool {
        return self.subviews[0].willExpand(in: context)
    }
}

public extension View {
    func overlay<V: View>(_ over: V, alignment: Alignment = .center) -> OverlayView<Self, V> {
        return OverlayView(under: self, over: over, alignment: alignment)
    }
}
