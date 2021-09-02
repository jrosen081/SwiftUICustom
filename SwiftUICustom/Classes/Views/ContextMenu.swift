//
//  ContextMenu.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/3/21.
//

import Foundation

@available(iOS 13, *)
public struct ContextMenu<Content: View, Menu: View>: View {
    private class InteractionDelegate: NSObject, UIContextMenuInteractionDelegate {
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: self.menuItems)
            }
        }
        
        var menuItems: [UIMenuElement] = []
    }
    let content: Content
    let menu: Menu
    @Environment(\.cell) var cell
    @Environment(\.currentStateNode) var currentNode
    @State private var interactionDelegate: InteractionDelegate = InteractionDelegate()
    
    public init(_ view: Content, menu: Menu) {
        self.content = view
        self.menu = menu
    }
    
    public var body: UIViewWrappingView<Content> {
        UIViewWrappingView(content: self.content) { underlyingView in
            if let cell = cell {
                cell.menuItems = self.menuItems
            } else {
                self.interactionDelegate.menuItems = menuItems
                let interaction = UIContextMenuInteraction(delegate: self.interactionDelegate)
                underlyingView.interactions.removeAll(where: { $0 is UIContextMenuInteraction })
                underlyingView.interactions.append(interaction)
            }
        }
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
    
    private var menuItems: [UIMenuElement] {
        menu.menuItems(selected: false, domNode: currentNode)
    }
}

@available(iOS 13, *)
extension View {
    func menuItems(selected: Bool, domNode: DOMNode) -> [UIMenuElement] {
        let expanding = self._makeSequence(currentNode: domNode).expanded(node: domNode).map(\.0.buildingBlock)
        return expanding.compactMap { $0 as? MenuItemAccessable & _BuildingBlock }.compactMap { $0.toItem(selected: selected, domNode: DOMNode(environment: domNode.environment, viewController: domNode.viewController, buildingBlock: $0)) }

    }
}

@available(iOS 13, *)
private protocol MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> UIMenuElement?
}

@available(iOS 14, *)
extension Menu: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> UIMenuElement? {
        guard let title = label.textValue else { return nil }
        return UIMenu(title: title, image: label.imageValue, identifier: nil, options: [], children: self.menuItems.menuItems(selected: selected, domNode: domNode))
    }
}

@available(iOS 13, *)
extension Button: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> UIMenuElement? {
        let items = self.content._makeSequence(currentNode: domNode).expanded(node: domNode).map(\.0)
        guard let title = items.compactMap(\.text).first else { return nil }
        let image = items.compactMap(\.image).first
        let action = UIAction(title: title, image: image, identifier: nil, discoverabilityTitle: nil, attributes: [], state: selected ? .on : .off) { _ in
            self.onClick()
        }
        return action
    }
}

@available(iOS 13, *)
extension Section: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> UIMenuElement? {
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: self.content.menuItems(selected: selected, domNode: domNode))

    }
}

@available(iOS 13, *)
extension Picker: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> UIMenuElement? {
        let allOptions = self.content
            ._makeSequence(currentNode: domNode)
            .expanded(node: domNode)
            .map(\.0.buildingBlock)
            .compactMap({  $0 as? _BuildingBlock & Taggable & MenuItemAccessable })
        let allPickerOptions = allOptions.compactMap {
            let isSelected = $0.taggedValue == AnyHashable(self.selectionValue.wrappedValue)
            guard let item = $0.toItem(selected: isSelected, domNode: DOMNode(environment: domNode.environment, viewController: domNode.viewController, buildingBlock: $0)) else { return nil }
            return (item, isSelected, $0.taggedValue)
        }.map { (element: UIMenuElement, selected: Bool, tag: AnyHashable) in
            UIAction(title: element.title, image: element.image, identifier: nil, discoverabilityTitle: nil, attributes: [], state: selected ? .on : .off) { _ in
                self.selectionValue.wrappedValue = tag.base as! SelectionValue
            }
        }
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: allPickerOptions)
    }
}

@available(iOS 13, *)
public extension View {
    func contextMenu<V: View>(@ViewBuilder _ menu: () -> V) -> ContextMenu<Self, V> {
        return ContextMenu(self, menu: menu())
    }
}
