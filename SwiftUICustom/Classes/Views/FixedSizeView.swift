//
//  FixedSizeView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/4/21.
//

import Foundation

public struct FixedSizeView<Content: View>: View {
    let content: Content
    let fixedHorizontal: Bool
    let fixedVertical: Bool
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: self.content) { wrapper in
            if fixedHorizontal {
                wrapper.setContentHuggingPriority(.required, for: .horizontal)
                wrapper.setContentCompressionResistancePriority(.required, for: .horizontal)
            }
            
            if fixedVertical {
                wrapper.setContentHuggingPriority(.required, for: .vertical)
                wrapper.setContentCompressionResistancePriority(.required, for: .vertical)
            }
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}
