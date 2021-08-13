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
    
    private var menuItems: [UIMenuElement] {
        menu.menuItems(selected: false)
    }
}

@available(iOS 13, *)
extension View {
    func menuItems(selected: Bool) -> [UIMenuElement] {
        let expanding = self.expanded()
        return expanding.compactMap { $0 as? MenuItemAccessable }.compactMap { $0.toItem(selected: selected) }

    }
}

@available(iOS 13, *)
private protocol MenuItemAccessable {
    func toItem(selected: Bool) -> UIMenuElement?
}

@available(iOS 14, *)
extension Menu: MenuItemAccessable {
    func toItem(selected: Bool) -> UIMenuElement? {
        guard let title = self.label as? Text else { return nil }
        return UIMenu(title: title.text, image: nil, identifier: nil, options: [], children: self.menuItems.menuItems(selected: selected))
    }
}

@available(iOS 13, *)
extension Button: MenuItemAccessable {
    func toItem(selected: Bool) -> UIMenuElement? {
        let items = self.content.expanded()
        guard let title = items.lazy.compactMap({ $0 as? Text }).first?.text else { return nil }
        let image = items.lazy.compactMap { $0 as? Image }.first?.image
        let action = UIAction(title: title, image: image, identifier: nil, discoverabilityTitle: nil, attributes: [], state: selected ? .on : .off) { _ in
            self.onClick()
        }
        return action
    }
}

@available(iOS 13, *)
extension Section: MenuItemAccessable {
    func toItem(selected: Bool) -> UIMenuElement? {
        return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: self.content.menuItems(selected: selected))

    }
}

@available(iOS 13, *)
// TODO: THIS CORRECTLy
extension Picker: MenuItemAccessable {
    func toItem(selected: Bool) -> UIMenuElement? {
        let allOptions = self.content.expanded().compactMap({  $0 as? _BuildingBlock & Taggable & MenuItemAccessable })
        let allPickerOptions = allOptions.compactMap {
            $0.toItem(selected: $0.taggedValue == AnyHashable(self.selectionValue.wrappedValue))
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
