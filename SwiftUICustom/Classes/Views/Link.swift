//
//  Link.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/19/21.
//

import Foundation

public struct Link<Label: View>: View {
    let label: Label
    let url: URL
    @Environment(\.openUrl) var openURL
    
    public init(_ str: String, url: URL) where Label == Text {
        self = Link(destination: url, label: { Text(str) })
    }
    
    public init(destination url: URL, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.url = url
    }
    
    public var body: OnTapGestureView<Label> {
        label.onTapGesture {
            openURL(url)
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}
