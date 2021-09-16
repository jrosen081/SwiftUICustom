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
        menu.menuItems(selected: false, domNode: currentNode).map(\.toMenuElement)
    }
}

extension View {
    func menuItems(selected: Bool, domNode: DOMNode) -> [MenuItem] {
        let expanding = self._makeSequence(currentNode: domNode).expanded(node: domNode).map(\.0.buildingBlock)
        return expanding.compactMap { $0 as? MenuItemAccessable & _BuildingBlock }.compactMap { $0.toItem(selected: selected, domNode: DOMNode(environment: domNode.environment, viewController: domNode.viewController, buildingBlock: $0))}

    }
}

private protocol MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> MenuItem?
}

indirect enum MenuItem {
    case menu(title: String, image: UIImage?, children: [MenuItem], inline: Bool)
    case action(title: String, image: UIImage?, selected: Bool, onClick: () -> Void, role: ButtonRole?)
    
    var title: String {
        switch self {
        case let .action(title, _, _, _, _):
            return title
        case let .menu(title,_, _, _):
            return title
        }
    }
    
    var image: UIImage? {
        switch self {
        case let .action(_, image, _, _, _):
            return image
        case let .menu(_, image, _, _):
            return image
        }
    }

    
    @available(iOS 13, *)
    var toMenuElement: UIMenuElement {
        switch self {
        case let .action(title, imaage, selected, onClick, role): return UIAction(title: title, image: imaage, identifier: nil, discoverabilityTitle: nil, attributes: role == .destructive ? .destructive : [], state: selected ? .on : .off, handler: {_ in onClick() })
        case let .menu(title, image, children, inline): return UIMenu(title: title, image: image, identifier: nil, options: inline ? .displayInline : [], children: children.map(\.toMenuElement))
        }
    }
}

@available(iOS 14, *)
extension Menu: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> MenuItem? {
        guard let title = label.textValue else { return nil }
        return .menu(title: title, image: label.imageValue, children: self.menuItems.menuItems(selected: selected, domNode: domNode), inline: false)
    }
}

extension Button: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> MenuItem? {
        let items = self.content._makeSequence(currentNode: domNode).expanded(node: domNode).map(\.0)
        guard let title = items.compactMap(\.text).first else { return nil }
        let image = items.compactMap(\.image).first
        return .action(title: title, image: image, selected: selected, onClick: onClick, role: self.role)
    }
}

extension Section: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> MenuItem? {
        return .menu(title: "", image: nil, children: self.content.menuItems(selected: selected, domNode: domNode), inline: true)

    }
}

extension Picker: MenuItemAccessable {
    func toItem(selected: Bool, domNode: DOMNode) -> MenuItem? {
        let allOptions = self.content
            ._makeSequence(currentNode: domNode)
            .expanded(node: domNode)
            .map(\.0.buildingBlock)
            .compactMap({  $0 as? _BuildingBlock & Taggable & MenuItemAccessable })
        let allPickerOptions = allOptions.compactMap {
            let isSelected = $0.taggedValue == AnyHashable(self.selectionValue.wrappedValue)
            guard let item = $0.toItem(selected: isSelected, domNode: DOMNode(environment: domNode.environment, viewController: domNode.viewController, buildingBlock: $0)) else { return nil }
            return (item, isSelected, $0.taggedValue)
        }.map { (element: MenuItem, selected: Bool, tag: AnyHashable) in
            return MenuItem.action(title: element.title, image: element.image, selected: selected, onClick: {
                self.selectionValue.wrappedValue = tag.base as! SelectionValue
            }, role: nil)
        }
        return .menu(title: "", image: nil, children: allPickerOptions, inline: true)
    }
}

@available(iOS 13, *)
public extension View {
    func contextMenu<V: View>(@ViewBuilder _ menu: () -> V) -> ContextMenu<Self, V> {
        return ContextMenu(self, menu: menu())
    }
}
