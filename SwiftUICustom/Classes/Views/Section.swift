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
    var buildingBlocks: [_BuildingBlock] { get }
}

struct UngroupedSection: SectionProtocol {
    let buildingBlocks: [_BuildingBlock]
    let headerView: _BuildingBlock? = nil
    let footerView: _BuildingBlock? = nil
}

public struct Section<Parent: View, Content: View, Footer: View>: View, SectionProtocol {
    let header: Parent
    let content: Content
    let footer: Footer
    
    public init(@ViewBuilder _ content: () -> Content) where Parent == EmptyView, Footer == EmptyView {
        self.header = EmptyView()
        self.footer = EmptyView()
        self.content = content()
    }
    
    public init(header: Parent, @ViewBuilder _ content: () -> Content) where Footer == EmptyView {
        self.header = header
        self.footer = EmptyView()
        self.content = content()
    }
    
    public init(footer: Footer, @ViewBuilder _ content: () -> Content) where Parent == EmptyView {
        self.header = EmptyView()
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
    
    var buildingBlocks: [_BuildingBlock] {
        return content.expanded()
    }
    
    public func _isEqual(toSameType other: Section<Parent, Content, Footer>, environment: EnvironmentValues) -> Bool {
        [headerView, footerView, content].compactMap { $0 }.isEqual(to: [other.headerView, other.footerView, other.content].compactMap { $0 }, environment: environment)
    }
    
    public func _hash(into hasher: inout Hasher, environment: EnvironmentValues) {
        [headerView, footerView, content].compactMap { $0 }.forEach { $0._hash(into: &hasher, environment: environment) }
    }
    
    public func _requestedSize(within size: CGSize, environment: EnvironmentValues) -> CGSize {
        content._requestedSize(within: size, environment: environment)
    }
}
