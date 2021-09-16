//
//  SwipeActionsView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/5/21.
//

import Foundation

public enum HorizontalEdge: Int {
    case trailing, leading
}

public struct SwipeActionsView<Body: View, Actions: View>: View {
    let edge: HorizontalEdge
    let allowsFullSwipe: Bool
    let underlyingBody: Body
    let actions: Actions
    @Environment(\.self) var environment
    @Environment(\.cell) var cell
    
    public var body: Body {
        if let cell = cell {
            let node =  DOMNode(environment: environment, viewController: environment.currentStateNode.viewController, buildingBlock: actions)
            node.environment = environment.withUpdates { $0.currentStateNode = node }
            let menuItems = actions.menuItems(selected: false, domNode: node)
            let allActions = menuItems.compactMap { item -> UIContextualAction? in
                switch item {
                case let .action(title, image, _, onClick, role):
                    let action = UIContextualAction(style: role == .destructive ? .destructive : .normal, title: title, handler: {_, _, completion in
                        completion(true)
                        onClick()
                    })
                    action.image = image
                    return action
                default: return nil
                }
            }
            let configuration = UISwipeActionsConfiguration(actions: allActions)
            configuration.performsFirstActionWithFullSwipe = allowsFullSwipe
            switch self.edge {
            case .leading: cell.leadingConfiguration = configuration
            case .trailing: cell.trailingConfiguration = configuration
            }
        }
        return underlyingBody
    }
    
    public var _viewInfo: _ViewInfo { _ViewInfo(isBase: true, baseBlock: self, layoutPriority: self.underlyingBody._viewInfo.layoutPriority) }
}


public extension View {
    func swipeActions<T>(edge: HorizontalEdge = .trailing, allowsFullSwipe: Bool = true, @ViewBuilder content: () -> T) -> SwipeActionsView<Self, T> where T : View {
        SwipeActionsView(edge: edge, allowsFullSwipe: allowsFullSwipe, underlyingBody: self, actions: content())
    }
}
