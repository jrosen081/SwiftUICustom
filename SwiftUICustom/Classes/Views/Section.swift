//
//  Section.swift
//  SwiftUICustom
//
//  Created by Jack Rosen on 10/1/20.
//

import Foundation

protocol SectionProtocol {
    var headerView: _BuildingBlock? { get }
    var footerView: _BuildingBlock? { get }
    func buildingBlocks(topNode: DOMNode) -> [(_BuildingBlock, DOMNode)]
}

struct UngroupedSection: SectionProtocol {
    let buildingBlocks: [(_BuildingBlock, DOMNode)]
    func buildingBlocks(topNode: DOMNode) -> [(_BuildingBlock, DOMNode)] {
        return buildingBlocks.flatMap { block, node -> [(_BuildingBlock, DOMNode)] in
            let sequence = block._makeSequence(currentNode: node).expanded(node: node)
            return sequence
        }
    }
    let headerView: _BuildingBlock? = nil
    let footerView: _BuildingBlock? = nil
}

public struct Section<Parent: View, Content: View, Footer: View>: View, SectionProtocol {
    let header: Parent?
    let content: Content
    let footer: Footer?
    
    public init(@ViewBuilder _ content: () -> Content) where Parent == EmptyView, Footer == EmptyView {
        self.header = nil
        self.footer = nil
        self.content = content()
    }
    
    public init(header: Parent, @ViewBuilder _ content: () -> Content) where Footer == EmptyView {
        self.header = header
        self.footer = nil
        self.content = content()
    }
    
    public init(footer: Footer, @ViewBuilder _ content: () -> Content) where Parent == EmptyView {
        self.header = nil
        self.footer = footer
        self.content = content()
    }
    
    public init(header: Parent, footer: Footer, @ViewBuilder _ content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    public var _isBase: Bool {
        return true
    }
    
    public var body: Content {
        return self.content
    }
    
    var headerView: _BuildingBlock? {
        return header
    }
    
    var footerView: _BuildingBlock? {
        return footer
    }
    
    func buildingBlocks(topNode: DOMNode) -> [(_BuildingBlock, DOMNode)] {
        self.content._makeSequence(currentNode: topNode).expanded(node: topNode)
    }
    
    public func _makeSequence(currentNode: DOMNode) -> _ViewSequence {
        return _ViewSequence(count: 1, viewGetter: {_, node in (_BuildingBlockRepresentable(buildingBlock: self), node)})
    }
}
