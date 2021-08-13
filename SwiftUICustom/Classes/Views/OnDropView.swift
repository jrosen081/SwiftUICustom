//
//  OnDropView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 7/7/21.
//

import Foundation

public protocol DropDelegate {
    func dropEntered(info: DropInfo)
    func dropExited(info: DropInfo)
    func dropUpdated(info: DropInfo) -> UIDropProposal?
    func validateDrop(info: DropInfo) -> Bool
    func performDrop(info: DropInfo) -> Bool
}

public extension DropDelegate {
    func dropEntered(info: DropInfo) {}
    func dropExited(info: DropInfo) {}
    func dropUpdated(info: DropInfo) -> UIDropProposal? { return nil }
    func validateDrop(info: DropInfo) -> Bool { return true }
}

public struct DropInfo {
    public let location: CGPoint
    let providers: [NSItemProvider]
    
    func hasItemsConforming(to types: [String]) -> Bool {
        return providers.contains(where: { provider in types.contains(where: provider.hasItemConformingToTypeIdentifier(_:)) })
    }
    
    func itemProviders(for types: [String]) -> [NSItemProvider] {
        return providers.filter({ provider in types.contains(where: provider.hasItemConformingToTypeIdentifier(_:)) })
    }
}

internal struct DropDelegateImpl: DropDelegate {
    let binding: Binding<Bool>?
    let perform: ([NSItemProvider], CGPoint) -> Bool
    let types: [String]
    
    func performDrop(info: DropInfo) -> Bool {
        perform(info.itemProviders(for: types), info.location)
    }
    
    func dropEntered(info: DropInfo) {
        binding?.wrappedValue = true
    }
    
    func dropExited(info: DropInfo) {
        binding?.wrappedValue = false
    }
}

public struct OnDropView<Content: View>: View {
    let dropDelegate: DropDelegate
    let content: Content
    let supportedTypes: [String]
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: content) { view in
            if view.subviews.count < 2 {
                view.addSubview(DroppingView(delegate: dropDelegate))
            }
            guard let subview = view.subviews[1] as? DroppingView else { return }
            subview.supportedTypes = supportedTypes
            subview.dropDelegate = dropDelegate
            subview.setupFullConstraints(subview, view.subviews[0], usingGreaterThan: true)
        }
    }
}

public extension View {
    func onDrop(of types: [String], delegate: DropDelegate) -> OnDropView<Self> {
        OnDropView(dropDelegate: delegate, content: self, supportedTypes: types)
    }
    
    func onDrop(of types: [String], isTargeted: Binding<Bool>? = nil, perform: @escaping ([NSItemProvider], CGPoint) -> Bool) -> OnDropView<Self> {
        onDrop(of: types, delegate: DropDelegateImpl(binding: isTargeted, perform: perform, types: types))
    }
    
    func onDrop(of types: [String], isTargeted: Binding<Bool>? = nil, perform: @escaping ([NSItemProvider]) -> Bool) -> OnDropView<Self> {
        onDrop(of: types, isTargeted: isTargeted, perform: { provider, _ in perform(provider) })
    }
}

private class DroppingView: UIView, UIDropInteractionDelegate {
    var supportedTypes: [String] = []
    var dropDelegate: DropDelegate
    
    init(delegate: DropDelegate) {
        self.dropDelegate = delegate
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
    }
    
    private func sessionToInfo(session: UIDropSession) -> DropInfo {
        DropInfo(location: session.location(in: self), providers: session.items.map(\.itemProvider))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        _ = dropDelegate.performDrop(info: sessionToInfo(session: session))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession) {
        dropDelegate.dropExited(info: sessionToInfo(session: session))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
        dropDelegate.dropEntered(info: sessionToInfo(session: session))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        let info = sessionToInfo(session: session)
        return info.hasItemsConforming(to: supportedTypes) && dropDelegate.validateDrop(info: info)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return dropDelegate.dropUpdated(info: sessionToInfo(session: session)) ?? UIDropProposal(operation: .copy)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
