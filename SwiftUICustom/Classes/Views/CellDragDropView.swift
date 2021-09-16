//
//  CellDragDropView.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 9/8/21.
//

import Foundation

public struct CellDragDropView<Content: View>: View {
    let content: Content
    let parentNode: DOMNode
    let index: Int
    @Environment(\.cell) var cell
    @Environment(\.tableView) var tableView
    let draggingFunction: ((IndexSet, Int) -> Void)?
    
    public var body: Content {
        cell?.nodeIndexPair = (parentNode, index)
        tableView?.draggingFunctions[parentNode] = draggingFunction
        return content
    }
    
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}
