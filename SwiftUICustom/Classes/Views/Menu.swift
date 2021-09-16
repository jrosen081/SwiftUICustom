//
//  Menu.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 8/4/21.
//

import Foundation

@available(iOS 14, *)
public struct Menu<Label: View, MenuItems: View>: View {
    let label: Label
    let menuItems: MenuItems
    @Environment(\.currentStateNode) var node
    
    public init(@ViewBuilder _ menuItems: () -> MenuItems, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.menuItems = menuItems()
    }
    
    public var body: some View {
        var button = Button(action: { }, content: {
            label
        })
        button.updateControl = { control in
            control.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: self.menuItems.menuItems(selected: false, domNode: node).map(\.toMenuElement))
            control.showsMenuAsPrimaryAction = true
        }
        return button
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}
