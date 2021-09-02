//
//  OnDragView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/7/21.
//

import Foundation

public struct OnDragView<Content: View>: View {
    let provider: () -> NSItemProvider
    let content: Content
    @Environment(\.self) var environment
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: self.content) { view in
            if view.subviews.count < 2 {
                view.addSubview(PreviewView(environment: environment, itemProvider: provider))
            }
            guard let previewView = view.subviews[1] as? PreviewView else { return }
            previewView.environment = environment
            previewView.itemProvider = provider
            previewView.previewView = view.subviews[0]
            previewView.setupFullConstraints(previewView, view.subviews[0], usingGreaterThan: true)
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}

public extension View {
    
    func onDrag(_ data: @escaping () -> NSItemProvider) -> OnDragView<Self> {
        OnDragView(provider: data, content: self)
    }
}

fileprivate class PreviewView: UIView, UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: itemProvider())
        dragItem.previewProvider = { [weak self] in
            guard let self = self, let previewView = self.previewView else { return nil }
            return UIDragPreview(view: previewView)
        }
        return [dragItem]
    }
    
    var itemProvider: () -> NSItemProvider
    var environment: EnvironmentValues
    weak var previewView: UIView?
    
    init(environment: EnvironmentValues, itemProvider: @escaping () -> NSItemProvider) {
        self.itemProvider = itemProvider
        self.environment = environment
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        addInteraction(dragInteraction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
